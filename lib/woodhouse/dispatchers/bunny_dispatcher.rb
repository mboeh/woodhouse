require 'bunny'
require 'connection_pool'
require 'woodhouse/dispatchers/common_amqp_dispatcher'

class Woodhouse::Dispatchers::BunnyDispatcher < Woodhouse::Dispatchers::CommonAmqpDispatcher

  def initialize(config)
    super
    @pool = new_pool
  end

  private

  def publish_job(job, exchange)
    exchange.publish(job.payload, :headers => job.arguments)
  end

  def run
    retried = false
    @pool.with do |conn|
      yield conn
    end
  rescue Bunny::ClientTimeout
    if retried
      raise
    else
      new_pool!
      retried = true
      retry
    end
  end

  private

  def new_pool!
    @pool = new_pool
  end

  def new_pool
    @bunny.stop if @bunny

    bunny = @bunny = Bunny.new(@config.server_info || {})
    @bunny.start

    ConnectionPool.new { bunny.create_channel }
  end

end
