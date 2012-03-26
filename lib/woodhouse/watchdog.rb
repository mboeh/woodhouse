require 'digest/md5'

class Woodhouse::Watchdog
  include Celluloid

  def initialize
    @actors ||= {}
    @observers = {}
  end

  def actor_status(actor, status, arguments)
    actor_history(actor).push(status, arguments)
    notify_observers(status, arguments)
  end

  def listen(&callback)
    id = Digest::MD5.hexdigest("#{Time.now}-#{rand}")
    add_observer(id, &callback)
    id
  end

  def add_observer(id, &callback)
    @observers[id] = callback
  end

  def remove_observer(id)
    @observers.delete(id)
  end

  private

  def actor_history(actor)
    @actors[actor] ||= ActorHistory.new(actor)
  end

  def notify_observers(*args)
    @observers.each do |_,callback|
      callback.call(*args)
    end
  end

  class ActorHistory

    def initialize(actor)
      @actor = actor
      @history = []
      @observers = {}
    end

    def push(status, arguments)
      @history.push([status, arguments, Time.now])
      @history.shift if @history.length > 20 # TODO: configure history length
    end

  end

  class Client
    
    def initialize(watchdog, actor)
      @watchdog = watchdog
      @actor   = actor
    end

    def register
      status("started")
    end

    def watch(job)
      job.watchdog = self
      status("working", job.to_hash)
      yield job
      status("finished", job.to_hash)
    rescue
      status("error", job.to_hash)
    ensure
      job.watchdog = nil
    end

    def status(message, arguments = {})
      @watchdog.actor_status!(actor, message.dup, arguments.dup)
    end

    def watched(job)
      job.watchdog = watchdog
      self
    end
  
    private

    attr_reader :actor
  end

  def self.register(actor)
    Woodhouse::Watchdog::Client.new(instance, actor).tap do |client|
      client.register
    end
  end

  def self.instance
    @instance ||= new
  end

  def self.listen(&block)
    instance.listen(&block)
  end

end
