module Woodhouse

  class Server
    include Celluloid
    include Woodhouse::Util

    attr_reader :layout, :node
    attr_accessor :configuration

    trap_exit :scheduler_died

    def initialize(keyw = {})
      self.layout        = keyw[:layout]
      self.node          = keyw[:node]
      self.configuration = keyw[:configuration] || Woodhouse.global_configuration
    end

    def layout=(value)
      expect_arg_or_nil :value, Woodhouse::Layout, value
      @previous_layout = @layout
      @layout = value ? value.frozen_clone : nil
    end

    def node=(value)
      @node = value || :default
    end

    def start
      # TODO: don't pass global config
      @scheduler ||= Woodhouse::Scheduler.new_link(configuration)
      return false unless ready_to_start?
      configuration.triggers.trigger :server_start
      dispatch_layout_changes
      true
    end

    def reload
      dispatch_layout_changes!
    end
    
    def ready_to_start?
      @node and @layout and @layout.node(@node)
    end

    # TODO: do this better
    def shutdown
      @scheduler.spin_down
      @scheduler.terminate
      configuration.triggers.trigger :server_end
      signal :shutdown
    end

    private

    def scheduler_died(actor, reason)
      signal :shutdown
    end

    def dispatch_layout_changes
      if @layout.nil?
        shutdown
      else
        apply_layout_changes @layout.changes_from(@previous_layout, @node)
      end
    end

    def apply_layout_changes(changes)
      if @scheduler
        changes.adds.each do |add|
          @scheduler.start_worker(add)
        end
        changes.drops.each do |drop|
          @scheduler.stop_worker(drop)
        end
      end
    end

  end

end
