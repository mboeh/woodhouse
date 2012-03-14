class Woodhouse::NodeConfiguration < 
  Struct.new(:registry, :server_info, :runner_type, :dispatcher_type, :logger, :default_threads)

  def initialize(*)
    super
    self.default_threads ||= 1
    yield self if block_given?
  end

  # TODO: don't like this.
  def make_dispatcher
    dispatcher.new(self)
  end

  # TODO: detect defaults based on platform
  def self.default
    new do |config|
      config.registry         = Woodhouse::MixinRegistry.new
      config.server_info      = nil
      config.runner_type      = Woodhouse::Runners::BunnyRunner
      config.dispatcher_type  = Woodhouse::LocalDispatcher
      config.logger           = Logger.new("/dev/null") 
    end
  end

end
