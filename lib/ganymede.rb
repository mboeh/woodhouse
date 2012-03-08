module Ganymede
  class GanymedeError < StandardError; end
  class GanymedeNotFoundError < GanymedeError; end
  class GanymedeConnectionError < GanymedeError; end
  class GanymedeConfigurationError < GanymedeError; end

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
require 'ganymede/layout'
require 'ganymede/scheduler'
require 'ganymede/server'
require 'ganymede/queue_criteria'
