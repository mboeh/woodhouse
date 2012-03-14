module Woodhouse

  class Server
    include Celluloid
    include Woodhouse::Util

    attr_reader :layout, :node

    def initialize(layout = nil, node = nil)
      self.layout = layout
      self.node = node
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
      @scheduler ||= Woodhouse::Scheduler.new_link(Woodhouse.global_configuration)
      dispatch_layout_changes
    end

    def reload
      dispatch_layout_changes!
    end
    
    # TODO: do this better
    def shutdown
      @scheduler.spin_down
      signal :shutdown
    end

    private

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
