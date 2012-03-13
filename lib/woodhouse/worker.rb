module Woodhouse::Worker
  
  def self.included(into)
    into.extend ClassMethods
    into.set_worker_name into.name unless into.name.nil?
  end

  module ClassMethods
    
    def worker_name
      @worker_name
    end

    def set_worker_name(name)
      if @worker_name
        raise ArgumentError, "cannot change worker name"
      else
        if name
          @worker_name = name.to_sym
          Woodhouse::MixinRegistry.register self
        end
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^asynch?_(.*)/
        if instance_methods(false).detect{|meth| meth.to_s == $1 }
          # TODO: dispatch job
        else
          super
        end
      else
        super
      end
    end

  end

end
