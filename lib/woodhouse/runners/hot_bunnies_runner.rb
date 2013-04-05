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
    status :spinning_up
    client = HotBunnies.connect(@config.server_info)
    channel = client.create_channel
    channel.prefetch = 1
    queue = channel.queue(@worker.queue_name)
    exchange = channel.exchange(@worker.exchange_name, :type => :headers)
    queue.bind(exchange, :arguments => @worker.criteria.amqp_headers)
    worker = Celluloid.current_actor
    status :subscribed
    queue.subscribe(:ack => true).each(:blocking => false) do |headers, payload|
      status :receiving
      begin
        job = make_job(headers, payload)
        if can_service_job?(job)
          if service_job(job)
            headers.ack
          else
            headers.reject
          end
        else
          status :rejected
          headers.reject
        end
        status :subscribed
      rescue => err
        status :error
        begin
          headers.reject
        ensure
          worker.bail_out(err)
        end
      end
    end
    wait :spin_down
    status :closing
  ensure
    client.close
  end

  def spin_down
    signal :spin_down
  end

  def bail_out(err)
    status :bailing_out, "#{err.class}: #{err.message}"
    raise Woodhouse::BailOut, "#{err.class}: #{err.message}"
  end

  private

  def make_job(message, payload)
    Woodhouse::Job.new(@worker.worker_class_name, @worker.job_method) do |job|
      job.arguments = message.properties.headers.inject({}) {|h,(k,v)|
        h[k.to_s] = v.to_s
        h
      }
      job.payload = payload
    end
  end

end
