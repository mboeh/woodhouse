class Woodhouse::NodeConfiguration < 
  Struct.new(:registry, :server_info, :worker_type, :dispatcher, :logger, :default_threads)

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
      config.registry    = Woodhouse::MixinRegistry.new
      config.server_info = nil
      config.worker_type = Woodhouse::BunnyWorkerProcess
      config.dispatcher  = Woodhouse::LocalDispatcher
      config.logger      = Logger.new("/dev/null") 
    end
  end

end
