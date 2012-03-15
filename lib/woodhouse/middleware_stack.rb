class Woodhouse::MiddlewareStack < Array

  def initialize(config)
    @config = config
  end

  def call(*args, &final)
    stack = make_stack.dup
    next_step = lambda {|*args|
      next_item = stack.shift
      if next_item.nil?
        final.call(*args)
      else
        next_item.call(*args, &next_step)
      end
    }
    next_step.call(*args)
  end

  private

  def make_stack
    @stack ||= 
      map do |item|
        if item.respond_to?(:call)
          item
        elsif item.respond_to?(:new)
          item.new(@config)
        else
          raise ArgumentError, "bad entry #{item.inspect} in middleware stack"
        end
      end
  end

end
