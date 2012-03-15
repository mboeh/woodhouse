class Woodhouse::NodeConfiguration
  include Woodhouse::Util

  attr_accessor :registry, :server_info, :runner_type, :dispatcher_type, :logger, :default_threads
  attr_accessor :dispatcher_middleware, :runner_middleware

  def initialize
    self.default_threads = 1
    self.dispatcher_middleware = Woodhouse::MiddlewareStack.new(self)
    self.runner_middleware = Woodhouse::MiddlewareStack.new(self)
    self.server_info = {}
    yield self if block_given?
  end

  def dispatcher
    @dispatcher ||= dispatcher_type.new(self)
  end

  def dispatcher_type=(value)
    if value.respond_to?(:to_sym)
      value = lookup_key(value, :Dispatcher)
    end
    @dispatcher = nil
    @dispatcher_type = value
  end

  def runner_type=(value)
    if value.respond_to?(:to_sym)
      value = lookup_key(value, :Runner)
    end
    @dispatcher = nil
    @runner_type = value
  end

  def server_info=(hash)
    @server_info = hash ? symbolize_keys(hash) : {}
  end

  private

  def lookup_key(key, namespace)
    const = Woodhouse.const_get("#{namespace}s").const_get("#{camelize(key.to_s)}#{namespace}")
    unless const
      raise NameError, "couldn't find Woodhouse::#{namespace}s::#{camelize(key.to_s)}#{namespace} (from #{key})"
    end
    const
  end

  def symbolize_keys(hash)
    hash.inject({}){|h,(k,v)|
      h[k.to_sym] = v
      h
    }
  end

  # TODO: detect defaults based on platform
  def self.default
    new do |config|
      config.registry         = Woodhouse::MixinRegistry.new
      config.server_info      = nil
      config.runner_type      = Woodhouse::Runners.guess
      config.dispatcher_type  = :local
      config.logger           = Logger.new("/dev/null") 
      config.dispatcher_middleware << Woodhouse::Middleware::LogDispatch
      config.runner_middleware     << Woodhouse::Middleware::LogJobs
      config.runner_middleware     << Woodhouse::Middleware::AssignLogger
    end
  end

end
