require 'bunny'

class Woodhouse::Dispatchers::BunnyDispatcher < Woodhouse::Dispatcher

  def initialize(config)
    super
    @bunny = Bunny.new(@config.server_info || {})
    @mutex = Mutex.new
  end

  private

  def deliver_job(job)
    @mutex.synchronize do
      @bunny.start
      exchange = @bunny.exchange(job.exchange_name, :type => :headers)
      exchange.publish(" ", :headers => job.arguments)
      @bunny.stop
    end
  end

end
