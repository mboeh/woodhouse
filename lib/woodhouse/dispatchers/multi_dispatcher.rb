# The eventual goal is for the AMQP dispatching to be handled by Poovey, not
# Woodhouse. This is the first step in that direction.
#
class Woodhouse::Dispatchers::MultiDispatcher < Woodhouse::Dispatcher

  attr_accessor :exchange
  
  def initialize(config)
    super
    self.exchange = Poovey.start
  end

  def route(criteria, keyw = {})
    dispatcher = keyw.fetch(:to)
    parameters = keyw.fetch(:only, {})

    # FIXME: this method of funnelling Woodhouse jobs over Poovey messages needs
    # to be formalized in one specific place.
    exchange.route(/^Woodhouse:#{criteria}/, parameters, proxy(dispatcher))
  end
  
  def fallback_to(dispatcher)
    exchange.fallback_to proxy(dispatcher)
  end

  def dispatch_job(job)
    deliver_job(job) # skip middleware
  end

  private

  # Need to convert Poovey messages to Woodhouse jobs
  def proxy(dispatcher)
    lambda{|message|
      dispatcher.dispatch_job(Woodhouse::Job.from_poovey_message(message))
    }
  end

  def deliver_job(job)
    exchange.deliver job
  end

end
