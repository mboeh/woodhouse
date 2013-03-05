module Woodhouse::Dispatchers

  def self.default_amqp_dispatcher
    if RUBY_ENGINE =~ /jruby/
      Woodhouse::Dispatchers::HotBunniesDispatcher
    else
      Woodhouse::Dispatchers::BunnyDispatcher
    end
  end

end

require 'woodhouse/dispatcher'
require 'woodhouse/dispatchers/local_dispatcher'
require 'woodhouse/dispatchers/bunny_dispatcher'
require 'woodhouse/dispatchers/hot_bunnies_dispatcher'
require 'woodhouse/dispatchers/local_pool_dispatcher'

Woodhouse::Dispatchers::AmqpDispatcher = Woodhouse::Dispatchers.default_amqp_dispatcher 
