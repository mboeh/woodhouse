require 'bunny'
require 'connection_pool'

class Woodhouse::Dispatchers::BunnyDispatcher < Woodhouse::Dispatcher

  def initialize(config)
    super
    @pool = new_pool
  end

  private

  def deliver_job(job)
    run do |conn|
      exchange = conn.exchange(job.exchange_name, :type => :headers)
      exchange.publish(" ", :headers => job.arguments)
    end
  end

  def deliver_job_update(job, data)
    run do |conn|
      exchange = conn.direct("woodhouse.progress")
      # establish durable queue to pick up updates
      conn.queue(job.job_id, :durable => true).bind(exchange, :routing_key => job.job_id)
      exchange.publish(data.to_json, :routing_key => job.job_id)
    end
  rescue => err
    Woodhouse.logger.warn("Error when dispatching job update: #{err.class}: #{err.message}")
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

    bunny = @bunny = Bunny.new((@config.server_info || {}).merge(:threaded => false))
    @bunny.start

    ConnectionPool.new { bunny.create_channel }
  end

end
