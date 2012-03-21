module Woodhouse

  # 
  # A Layout describes the configuration of a set of Woodhouse Server instances.
  # Each Server runs all of the workers assigned to a single Node.
  #
  # Layouts and their contents (Node and Worker instances) are all plain data,
  # suitable to being serialized, saved out, passed around, etc.
  #
  # Woodhouse clients do not need to know anything about the Layout to dispatch
  # jobs, but servers rely on the Layout to know which jobs to serve. The basic
  # process of setting up a Woodhouse server is to create a layout with one or
  # more nodes and then pass it to Woodhouse::Server to serve.
  # 
  # There is a default layout suitable for many applications, available as
  # Woodhouse::Layout.default. It has a single node named :default, which has
  # the default node configuration -- one worker for every job. If you do not
  # need to distribute different sets of jobs to different workers, the default
  # layout should serve you.
  # 
  # TODO: A nicer DSL for creating and tweaking Layouts.
  #
  class Layout
    include Woodhouse::Util

    def initialize
      @nodes = []
    end

    # Returns a frozen list of the nodes assigned to this layout.
    def nodes
      @nodes.frozen? ? @nodes : @nodes.dup.freeze
    end

    # Adds a Node to this layout. If +node+ is a Symbol, a Node will be
    # automatically created with that name.
    #
    #   # Example:
    #
    #   layout.add_node Woodhouse::Layout::Node.new(:isis)
    #
    #   # Is equivalent to
    #
    #   layout.add_node :isis
    #
    def add_node(node)
      if node.respond_to?(:to_sym)
        node = Woodhouse::Layout::Node.new(node.to_sym)  
      end
      expect_arg :node, Woodhouse::Layout::Node, node
      @nodes << node
    end

    # Looks up a Node by name and returns it.
    def node(name)
      name = name.to_sym
      @nodes.detect{|node|
        node.name == name
      }
    end

    # Returns a frozen copy of this Layout and all of its child Node and
    # Worker objects. Woodhouse::Server always takes a frozen copy of the
    # layout it is given. It is thus safe to modify the same layout
    # subsequently, and the changes only take effect when the layout is
    # passed to the server again and Woodhouse::Server#reload is called.
    def frozen_clone
      clone.tap do |cloned|
        cloned.nodes = @nodes.map{|node| node.frozen_clone }.freeze
        cloned.freeze
      end
    end

    # Returns a set of Changes necessary to move from +other_layout+ to this
    # layout. This is used to permit live reconfiguration of servers by only
    # spinning up and down nodes/workers which have changed.
    def changes_from(other_layout, node)
      Woodhouse::Layout::Changes.new(self, other_layout, node)
    end

    # The default layout, for convenience purposes. Has one node +:default+,
    # which has the default configuration (see Woodhouse::Layout::Node#default_configuration!)
    def self.default
      new.tap do |layout|
        layout.add_node :default
        layout.node(:default).default_configuration!(Woodhouse.global_configuration)
      end
    end

    protected

    attr_writer :nodes
    
    # 
    # A Node describes the set of workers present on a single Server.
    #
    # More information about Woodhouse's layout system can be found in the
    # documentation for Woodhouse::Layout.
    #
    class Node
      include Woodhouse::Util

      attr_reader :name

      def initialize(name)
        @name = name.to_sym
        @workers = []
      end

      # Returns a frozen list of workers assigned to this node.
      def workers
        @workers.frozen? ? @workers : @workers.dup.freeze
      end
      
      # Adds a Worker to this node.
      def add_worker(worker)
        expect_arg :worker, Woodhouse::Layout::Worker, worker
        @workers << worker
      end

      def remove_worker(worker)
        expect_arg :worker, Woodhouse::Layout::Worker, worker
        @workers.delete(worker)
      end

      def clear
        @workers.clear
      end

      # Configures this node with one worker per job (jobs obtained 
      # from Registry#each). The +default_threads+ value of the given
      # +config+ is used to determine how many threads should be
      # assigned to each worker.
      def default_configuration!(config, options = {})
        options[:threads] ||= config.default_threads
        config.registry.each do |name, klass|
          klass.public_instance_methods(false).each do |method|
            add_worker Woodhouse::Layout::Worker.new(name, method, options)
          end
        end
      end
      
      # Used by Layout#frozen_clone
      def frozen_clone # :nodoc:
        clone.tap do |cloned|
          cloned.workers = @workers.map{|worker| worker.frozen_clone }.freeze
          cloned.freeze
        end
      end

      protected

      attr_writer :workers
    end

    # 
    # A Worker describes a single job that is performed on a Server.
    # One or more Runner actors are created for every Worker in a Node.
    #
    # Any Worker has three parameters used to route jobs to it:
    #
    # +worker_class_name+:: 
    #   This is generally a class name. It's looked up
    #   in a Registry and used to instantiate a job object.
    # +job_method+:: 
    #   This is a method on the object called up with +worker_class_name+.
    # +criteria+:: 
    #   A hash of values (actually, a QueueCriteria object) used
    #   to filter only specific jobs to this worker. When a job is dispatched,
    #   its +arguments+ are compared with a worker's +criteria+. This is
    #   done via an AMQP headers exchange (TODO: need to have a central document
    #   to reference on how Woodhouse uses AMQP and jobs are dispatched)
    #
    class Worker
      attr_reader :worker_class_name, :job_method, :threads, :criteria

      def initialize(worker_class_name, job_method, opts = {})
        opts = opts.clone
        self.worker_class_name = worker_class_name
        self.job_method = job_method
        self.threads = opts.delete(:threads) || 1
        self.criteria = opts.delete(:only)
        unless opts.keys.empty? 
          raise ArgumentError, "unknown option keys: #{opts.keys.inspect}"
        end
      end
      
      def exchange_name
        "#{worker_class_name}_#{job_method}".downcase
      end
      
      def queue_name
        exchange_name + criteria.queue_key
      end

      def worker_class_name=(value)
        @worker_class_name = value.to_sym
      end

      def job_method=(value)
        @job_method = value.to_sym
      end

      def threads=(value)
        @threads = value.to_i
      end

      def criteria=(value)
        @criteria = Woodhouse::QueueCriteria.new(value).freeze
      end

      def frozen_clone
        clone.freeze
      end

      def describe
        "#@worker_class_name##@job_method(#{@criteria.describe})"
      end

      # TODO: want to recognize increases and decreases in numbers of
      # threads and make minimal changes
      def ==(other)
        [worker_class_name, job_method, 
          threads, criteria] ==
        [other.worker_class_name, other.job_method,
          other.threads, other.criteria]
      end

    end
    
    # 
    # A diff between two Layouts, used to determine what workers need to be
    # spun up and down when a layout change is sent to a Server.
    #
    class Changes

      def initialize(new_layout, old_layout, node_name)
        @new_layout = new_layout
        @new_node = @new_layout && @new_layout.node(node_name)
        @old_layout = old_layout
        @old_node = @old_layout && @old_layout.node(node_name)
        @node_name = node_name
      end

      def adds
        new_workers.reject{|worker|
          old_workers.member? worker
        }
      end

      def drops
        old_workers.reject{|worker|
          new_workers.member? worker
        }
      end
      
      private

      def old_workers
        @old_workers ||= @old_node ? @old_node.workers : []
      end

      def new_workers
        @new_workers ||= @new_node ? @new_node.workers : []
      end

    end

  end

end
