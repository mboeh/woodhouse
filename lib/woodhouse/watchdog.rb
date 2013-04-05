class Woodhouse::Watchdog
  include Celluloid

  def initialize
    @actors = {}
    @listeners = []
  end

  def report(id, status)
    last_status = @actors[id]
    @actors[id] = status
    notify id, Transition.new(last_status, status)
  end

  def listen(listener)
    @listeners << listener
  end

  private

  def notify(id, keyw = {})
    @listeners.each do |listen|
      listen.call id, keyw
    end
  end

  class << self

    def instance
      Celluloid::Actor[:woodhouse_watchdog]
    end

    def start
      @supervisor ||= supervise_as :woodhouse_watchdog
    end

    def stop
      if @supervisor
        supervisor, @supervisor = @supervisor, nil
        supervisor.terminate
      end
    end

    def client(id = nil)
      Client.new(instance, id)
    end

    def listen(listener = nil, &blk)
      if instance
        instance.listen listener || blk
      end
    end

  end

  class Transition
    attr_reader :old, :new

    def initialize(old, new)
      @old = old
      @new = new
    end

    def name
      "#{old_name} -> #{new_name}"
    end

    def old_name
      old && old.name
    end

    def new_name
      new && new.name
    end

    def message
      new.message
    end

    def duration
      old && new.time - old.time
    end

    def duration_s
      duration && " (#{duration}s)"
    end

    def to_s
      "{ #{name} } #{message}#{duration_s}"
    end

  end

  class Status
    attr_reader :name, :message, :time

    def initialize(name, message, time = Time.now)
      @name    = name.to_sym
      @message = message.dup.freeze
      @time    = time.dup.freeze

      freeze
    end
  end

  class Client

    def initialize(watchdog, id = nil)
      @watchdog = watchdog
      @id = id || detect_id || Celluloid.uuid
    end

    def detect_id
      Celluloid.current_actor.object_id
    end

    def report(name, message)
      if @watchdog
        @watchdog.report @id, Status.new(name, message)
      end
    end

  end

end
