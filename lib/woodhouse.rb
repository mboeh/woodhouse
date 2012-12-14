module Woodhouse
  WoodhouseError = Class.new(StandardError)
  WorkerNotFoundError = Class.new(WoodhouseError)
  ConnectionError = Class.new(WoodhouseError)
  ConfigurationError = Class.new(WoodhouseError)

  module Util
    
    private

    def expect_arg(name, klass, value)
      unless value.kind_of?(klass)
        raise ArgumentError, "expected #{name} to be a #{klass.name}, got #{value.class}"
      end
    end

    def expect_arg_or_nil(name, klass, value)
      expect_arg(name, klass, value) unless value.nil?
    end
  
    # Cheap knockoff, suffices for my simple purposes
    def camelize(string)
      string.split(/_/).map{ |word| word.capitalize }.join('')
    end

  end

  # TODO: hate keeping global state in this class. I need to push
  # some of this down into NodeConfiguration or something like it.
  module GlobalMethods 

    def global_configuration
      @global_configuration ||= Woodhouse::NodeConfiguration.default
    end

    def configure
      @global_configuration ||= Woodhouse::NodeConfiguration.default
      yield @global_configuration
    end
  
    def global_layout
      @global_layout ||= Woodhouse::Layout.default
    end

    def layout
      @global_layout ||= Woodhouse::Layout.new
      yield Woodhouse::LayoutBuilder.new(Woodhouse.global_configuration, @global_layout)
    end

    # Returns +true+ on JRuby, Rubinius, or MRI 1.9. +false+ otherwise.
    def threading_safe?
      RUBY_VERSION.to_f >= 1.9 or %w[jruby rbx].include?(RUBY_ENGINE)
    end

    def dispatch(*a)
      global_configuration.dispatcher.dispatch(*a)
    end

    def dispatch_job(job)
      global_configuration.dispatcher.dispatch_job(job)
    end

  end

  extend GlobalMethods

end

require 'fiber18'
require 'celluloid'
require 'poovey' 
require 'woodhouse/job'
require 'woodhouse/layout'
require 'woodhouse/layout_builder'
require 'woodhouse/scheduler'
require 'woodhouse/server'
require 'woodhouse/queue_criteria'
require 'woodhouse/node_configuration'
require 'woodhouse/registry'
require 'woodhouse/mixin_registry'
require 'woodhouse/worker'
require 'woodhouse/job_execution'
require 'woodhouse/runners'
require 'woodhouse/dispatchers'
require 'woodhouse/middleware_stack'
require 'woodhouse/middleware'
require 'woodhouse/rails'
require 'woodhouse/process'
require 'woodhouse/watchdog'
