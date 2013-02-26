#
# A Dispatcher implementation that uses hot_bunnies, a JRuby AMQP client using the
# Java client for RabbitMQ. This class can be loaded if hot_bunnies is not
# available, but it will fail upon initialization. If you want to use this
# runner (it's currently the only one that works very well), make sure to
# add
#
#   gem 'hot_bunnies'
#
# to your Gemfile.
#
class Woodhouse::Dispatchers::HotBunniesDispatcher < Woodhouse::Dispatcher

  begin
    require 'hot_bunnies'
  rescue LoadError => err
    define_method(:initialize) {|*args|
      raise err
    }
  else
    def initialize(config)
      super
      @client = HotBunnies.connect(config.server_info).create_channel
    end
  end

  private
  
  # FIXME: most of this is verbatim from BunnyDispatcher
  attr_reader :client
  
  def deliver_job(job)
    exchange = client.exchange(job.exchange_name, :type => :headers)
    exchange.publish(" ", :headers => job.arguments)
  end

  def deliver_job_update(job, data)
    exchange = client.exchange("woodhouse.progress", :type => :direct)
    # establish durable queue to pick up updates
    client.queue(job.job_id, :durable => true).bind(exchange, :routing_key => job.job_id)
    exchange.publish(data.to_json, :routing_key => job.job_id)
  end

end
