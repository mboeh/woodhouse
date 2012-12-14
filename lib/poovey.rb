require 'celluloid'

module Poovey

  class << Poovey
    
    attr_accessor :local_exchange

    def start
      self.local_exchange ||= Poovey::Exchange.new(Poovey::LinearDispatcher.new)
    end

    def criteria(*args)
      Poovey::Criteria.from(*args)
    end

    alias [] criteria

    def message(*args)
      Poovey::Message.from(*args)
    end

  end

  class Message
    attr_accessor :name, :parameters, :payload

    def initialize(name, parameters, payload = nil)
      self.name       = name
      self.payload    = payload
      self.parameters = parameters

      yield self if block_given?
      freeze
    end

    def name_matches?(name_criteria)
      name_criteria === name
    end

    def parameter_matches?(param_name, param_criteria)
      param_criteria === parameters[param_name]
    end

    def to_poovey_message
      self
    end

    def self.from(*args)
      if args.length == 1
        arg = args.first
        if arg.respond_to?(:to_poovey_message)
          arg.to_poovey_message
        else
          new(arg, {})
        end
      else
        new(*args)
      end
    end
  end

  class Criteria

    def initialize(name, parameters = {})
      self.name       = name
      self.parameters = parameters

      freeze
    end

    def ==(other)
      name == other.name and parameters == other.parameters
    end

    def matches?(message)
      name_matches?(message) and parameters_match?(message)
    end

    alias === matches?

    def name_matches?(message)
      message.name_matches?(name)
    end

    def parameters_match?(message)
      parameters.all? do |name, value|
        message.parameter_matches?(name, value)
      end
    end

    def to_poovey_criteria
      self
    end

    def self.from(*args)
      if args.length == 1
        arg = args.first
        if arg.respond_to?(:to_poovey_criteria)
          arg.to_poovey_criteria
        else
          new(arg, {})
        end
      else
        new(*args)
      end
    end
      
    protected

    attr_accessor :name, :parameters

    private

    def stringify_values(hash)
      hash.inject({}) {|h,(k,v)|
        h[k.to_s] = v.to_s
        h
      }
    end

    def parameters=(params)
      params ||= {}
      @parameters = stringify_values(params).freeze
    end

  end

  class Exchange
    attr_accessor :dispatcher

    def initialize(dispatcher)
      self.dispatcher = dispatcher  
    end

    def route(*args, listener)
      criteria = Poovey.criteria(*args)
      ident = dispatcher.new_route_identifier criteria, listener

      dispatcher.register_route ident, criteria, listener

      ident
    end

    def unroute(route_identifier)
      dispatcher.unregister_route(route_identifier)
    end

    def deliver(*message)
      message = Poovey.message(*message)
      dispatcher.deliver!(message)
      message
    end

    def fallback_to(listener)
      dispatcher.fallback_listener = listener
    end

  end

  class BasicDispatcher
    attr_accessor :fallback_listener

    def initialize(keyw = {})
      if keyw[:behavior]
        extend keyw[:behavior]
      end
      self.fallback_listener = keyw[:fallback]

      after_initialize(keyw)
    end

    def deliver(message)
      listener = choose_listener(message)

      if listener
        listener.call(message)
      else
        fallback(message)
      end

      message
    end

    def after_initialize(keyw = {})

    end

    def fallback(message)
      if fallback_listener
        fallback_listener.call(message)
      end
    end

    def new_route_identifier(criteria, listener)
      [criteria.to_s, listener.object_id]
    end

    def register_route(identifier, criteria, listener)
      raise NotImplementedError, "children of #{self.class} must implement register_route"
    end

    def unregister_route(identifier)
      raise NotImplementedError, "children of #{self.class} must implement unregister_route"
    end

    def choose_listener(message)
      raise NotImplementedError, "children of #{self.class} must implement choose_listener"
    end

  end

  class SynchronousDispatcher < BasicDispatcher
    alias deliver! deliver
  end

  class CelluloidDispatcher < BasicDispatcher
    include Celluloid
  end

  # A Dispatcher which dispatches messages to listeners in the order they were registered.
  module LinearDispatchBehavior
    
    def after_initialize(keyw = {})
      super
      @routes = {}
    end

    def register_route(identifier, criteria, listener)
      @routes[identifier] = [criteria, listener]
    end

    def unregister_route(identifier)
      @routes.delete identifier
    end

    def choose_listener(message)
      @routes.each do |identifier, (criteria, listener)|
        return listener if criteria === message
      end
      nil
    end

  end

  class LinearDispatcher < CelluloidDispatcher
    include LinearDispatchBehavior
  end

end
