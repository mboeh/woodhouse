module Woodhouse
  class WoodhouseError < StandardError; end
  class WoodhouseNotFoundError < WoodhouseError; end
  class WoodhouseConnectionError < WoodhouseError; end
  class WoodhouseConfigurationError < WoodhouseError; end

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

  end

end

require 'fiber18'
require 'celluloid'
require 'woodhouse/layout'
require 'woodhouse/scheduler'
require 'woodhouse/server'
require 'woodhouse/queue_criteria'
require 'woodhouse/worker_process'
require 'woodhouse/node_configuration'
