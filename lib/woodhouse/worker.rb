#
# Classes which include this module become automatically visible to
# MixinRegistry (the default way of finding jobs in Woodhouse).
# All public methods of the class are automatically made available as
# jobs.
#
# Classes including Woodhouse::Worker also get access to the +logger+
# method, which will be the same logger globally configured for the current
# Layout.
#
# Classes including Woodhouse::Worker also have convenience shortcuts
# for dispatching jobs. Any job defined on the class can be dispatched
# asynchronously by calling ClassName.async_job_name(options).
#
# == Example
#
#   class PamPoovey
#     include Woodhouse::Worker
#
#     # This is available as the job PamPoovey#do_hr
#     def do_hr(options)
#       logger.info "Out comes the dolphin puppet"
#     end
#
#     private
#     
#     # This is not picked up as a job
#     def fight_club
#       # ...
#     end
#   end
#
#   # later ...
#   
#   Woodhouse::MixinRegistry.new[:PamPoovey] # => PamPoovey
#   PamPoovey.async_do_hr(:employee => "Lana")
#
module Woodhouse::Worker
  
  def self.included(into)
    into.extend ClassMethods
    into.set_worker_name into.name unless into.name.nil?
  end

  # The current Woodhouse logger. Set by the runner. Don't expect it to be set
  # if you create the object yourself. If you want to be able to run job methods
  # directly, you should account for setting +logger+.
  attr_accessor :logger

  module ClassMethods
    
    def worker_name
      @worker_name
    end

    # Sets the name for this worker class if not already set (i.e., if it's
    # an anonymous class). The first time the name for the worker is set,
    # it becomes registered with MixinRegistry. After that, attempting to
    # change the worker class will raise ArgumentError.
    def set_worker_name(name)
      if @worker_name
        raise ArgumentError, "cannot change worker name"
      else
        if name and !name.empty?
          @worker_name = name.to_sym
          Woodhouse::MixinRegistry.register self
        end
      end
    end

    # You can dispatch a job +baz+ on class +FooBar+ by calling FooBar.async_baz.
    def method_missing(method, *args, &block)
      if method.to_s =~ /^asynch?_(.*)/
        if instance_methods(false).detect{|meth| meth.to_s == $1 }
          Woodhouse.dispatch(@worker_name, $1, args.first)
        else
          super
        end
      else
        super
      end
    end

  end

end
