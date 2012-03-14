class Woodhouse::NodeConfiguration
  include Woodhouse::Util

  attr_accessor :registry, :server_info, :runner_type, :dispatcher_type, :logger, :default_threads

  def initialize
    self.default_threads ||= 1
    yield self if block_given?
  end

  # TODO: don't like this.
  def make_dispatcher
    dispatcher.new(self)
  end

  def dispatcher_type=(value)
    if value.respond_to?(:to_sym)
      value = lookup_key(value, :Dispatcher)
    end
    @dispatcher_type = value
  end

  def runner_type=(value)
    if value.respond_to?(:to_sym)
      value = lookup_key(value, :Runner)
    end
    @runner_type = value
  end

  private

  def lookup_key(key, namespace)
    const = Woodhouse.const_get("#{namespace}s").const_get("#{camelize(key.to_s)}#{namespace}")
    unless const
      raise NameError, "couldn't find Woodhouse::#{namespace}s::#{camelize(key.to_s)}#{namespace} (from #{key})"
    end
    const
  end

  # TODO: detect defaults based on platform
  def self.default
    new do |config|
      config.registry         = Woodhouse::MixinRegistry.new
      config.server_info      = nil
      config.runner_type      = :bunny
      config.dispatcher_type  = :local
      config.logger           = Logger.new("/dev/null") 
    end
  end

end
