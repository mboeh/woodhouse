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

require 'woodhouse/dispatchers/common_amqp_dispatcher'

class Woodhouse::Dispatchers::HotBunniesDispatcher < Woodhouse::Dispatchers::CommonAmqpDispatcher

  begin
    require 'hot_bunnies'
  rescue LoadError => err
    define_method(:initialize) {|*args|
      raise err
    }
  else
    def initialize(config)
      super
      new_connection 
      @mutex = Mutex.new 
    end
  end

  private
  
  def run
    @mutex.synchronize do
      yield @channel
    end
  end

  def publish_job(job, exchange)
    exchange.publish(" ", :properties => { :headers => job.arguments })
  end

  def new_connection
    @connection = HotBunnies.connect(@config.server_info)
    @channel = @connection.create_channel
  end

end
