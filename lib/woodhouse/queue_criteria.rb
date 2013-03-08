module Woodhouse

  class QueueCriteria
    attr_reader :criteria
    attr_accessor :exclusive

    def initialize(values = {}, flags = nil)
      flags ||= {}
      self.exclusive ||= flags[:exclusive]
      if values.kind_of?(self.class)
        values = values.criteria
      end
      unless values.nil?
        @criteria = stringify_values(values).freeze
      end
    end

    def ==(other)
      @criteria == other.criteria
    end

    def describe
      @criteria.inspect
    end

    def amqp_headers
      # TODO: needs to be smarter
      @criteria ? @criteria.merge('x-match' => 'all') : {}
    end

    def queue_key
      @criteria ? @criteria.map{|k,v|
        "#{k.downcase}_#{v.downcase}"
      }.join("_") : ""
    end

    def matches?(args)
      return true if @criteria.nil?
      return false if exclusive? and @criteria.length != args.keys.reject{|k| k =~ /^_/ }.length

      @criteria.all? do |key, val|
        args[key] == val
      end
    end

    def exclusive?
      !!exclusive
    end

    private

    def stringify_values(hash)
      hash.inject({}) {|h,(k,v)|
        h[k.to_s] = v.to_s
        h
      }
    end

  end

end
