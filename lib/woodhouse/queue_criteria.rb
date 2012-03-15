module Woodhouse

  class QueueCriteria
    attr_reader :criteria

    def initialize(opts = {})
      if opts.kind_of?(self.class)
        opts = opts.criteria
      end
      unless opts.nil?
        @criteria = opts.frozen? ? opts : opts.dup.freeze
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

    def matches?(args)
      return true if @criteria.nil?
      @criteria.all? do |key, val|
        args[key] == val.to_s
      end
    end

  end

end
