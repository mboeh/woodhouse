require 'bunny'

class Woodhouse::BunnyDispatcher < Woodhouse::Dispatcher

  def initialize(config)
    super
    @bunny = Bunny.new(@config.server_info)
  end

  def dispatch_job(job)
    @bunny.start
    exchange = @bunny.exchange(job.exchange_name, :type => :headers)
    exchange.publish(" ", :headers => job.arguments)
    @bunny.stop
  end

end
