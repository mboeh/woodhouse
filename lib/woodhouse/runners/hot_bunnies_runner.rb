#
# A Runner implementation that uses hot_bunnies, a JRuby AMQP client using the
# Java client for RabbitMQ. This class can be loaded if hot_bunnies is not
# available, but it will fail upon initialization. If you want to use this
# runner (it's currently the only one that works very well), make sure to
# add
#
#   gem 'hot_bunnies'
#
# to your Gemfile. This runner will automatically be used in JRuby.
#
class Woodhouse::Runners::HotBunniesRunner < Woodhouse::Runner
  begin
    require 'hot_bunnies'
  rescue LoadError => err
    define_method(:initialize) {|*args|
      raise err
    }
  end

  def subscribe
    client = HotBunnies.connect(@config.server_info || {})
    channel = client.create_channel
    channel.prefetch = 1
    queue = channel.queue(@worker.queue_name)
    exchange = channel.exchange(@worker.exchange_name, :type => :headers)
    queue.bind(exchange, :arguments => @worker.criteria.amqp_headers)
    queue.subscribe(:ack => true).each(:blocking => false) do |headers, msg|
      begin
        job = make_job(headers)
        if can_service_job?(job)
          service_job(job)
          headers.ack
        else
          headers.reject
        end
      rescue => err
        @config.logger.error("Error bubbled up out of worker. This shouldn't happen. #{err.message}")
        err.backtrace.each do |btr|
          @config.logger.error("  #{btr}")
        end
        spin_down
      end
    end
    wait :spin_down
  end

  def spin_down
    signal :spin_down
  end

  private

  def make_job(headers)
    Woodhouse::Job.new(@worker.worker_class_name, @worker.job_method) do |job|
      begin
        job.arguments = headers.properties.headers.inject({}) {|h,(k,v)|
          h[k.to_sym] = v.to_s
          h
        }
      rescue => err
        spin_down
      end
    end
  end

end
