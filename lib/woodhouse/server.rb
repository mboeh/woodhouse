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
      dispatch_layout_changes
    end

    def reload
      dispatch_layout_changes!
    end

    def shutdown
      # TODO
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
      # TODO
    end

  end

end
