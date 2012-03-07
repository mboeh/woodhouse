module Ganymede

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

  end

end
