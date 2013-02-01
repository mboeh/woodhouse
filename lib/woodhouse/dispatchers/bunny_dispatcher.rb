require 'bunny'

class Woodhouse::Dispatchers::BunnyDispatcher < Woodhouse::Dispatcher

  def initialize(config)
    super
    @bunny = Bunny.new(@config.server_info || {})
    @mutex = Mutex.new
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
      exchange.publish(data.to_json, :routing_key => job.job_id)
    end
  end

  def run
    @mutex.synchronize do
      @bunny.start unless @bunny.connected?
      yield
    end
  end

end
