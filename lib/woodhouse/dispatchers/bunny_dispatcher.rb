require 'bunny'

class Woodhouse::Dispatchers::BunnyDispatcher < Woodhouse::Dispatcher

  def initialize(config)
    super
    @bunny = Bunny.new(@config.server_info || {})
    @bunny.start
  end

  private

  def deliver_job(job)
    run do
      exchange = @bunny.exchange(job.exchange_name, :type => :headers)
      exchange.publish(" ", :headers => job.arguments)
    end
  end

  def deliver_job_update(job, data)
    run do
      exchange = @bunny.direct("woodhouse.progress")
      # establish durable queue to pick up updates
      @bunny.queue(job.job_id, :durable => true).bind(exchange, :routing_key => job.job_id)
      exchange.publish(data.to_json, :routing_key => job.job_id)
    end
  end

  def run
    yield
  end

end
