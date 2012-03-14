module Woodhouse

  class Layout
    include Woodhouse::Util

    def initialize
      @nodes = []
    end

    def nodes
      @nodes.frozen? ? @nodes : @nodes.dup.freeze
    end

    def add_node(node)
      if node.respond_to?(:to_sym)
        node = Woodhouse::Layout::Node.new(node.to_sym)  
      end
      expect_arg :node, Woodhouse::Layout::Node, node
      @nodes << node
    end

    def node(name)
      name = name.to_sym
      @nodes.detect{|node|
        node.name == name
      }
    end

    def frozen_clone
      clone.tap do |cloned|
        cloned.nodes = @nodes.map{|node| node.frozen_clone }.freeze
        cloned.freeze
      end
    end

    def changes_from(other_layout, node)
      Woodhouse::Layout::Changes.new(self, other_layout, node)
    end

    def self.default
      new.tap do |layout|
        layout.add_node :default
        layout.node(:default).default_configuration!(Woodhouse.global_configuration)
      end
    end

    protected

    attr_writer :nodes
    
    class Node
      include Woodhouse::Util

      attr_reader :name

      def initialize(name)
        @name = name.to_sym
        @workers = []
      end

      def workers
        @workers.frozen? ? @workers : @workers.dup.freeze
      end

      def add_worker(worker)
        expect_arg :worker, Woodhouse::Layout::Worker, worker
        @workers << worker
      end

      def default_configuration!(config)
        config.registry.each do |name, klass|
          klass.public_instance_methods(false).each do |method|
            add_worker Woodhouse::Layout::Worker.new(name, method, :threads => config.default_threads)
          end
        end
      end
      
      def frozen_clone
        clone.tap do |cloned|
          cloned.workers = @workers.map{|worker| worker.frozen_clone }.freeze
          cloned.freeze
        end
      end

      protected

      attr_writer :workers
    end

    class Worker
      attr_reader :worker_class_name, :job_method, :threads, :criteria

      def initialize(worker_class_name, job_method, opts = {})
        self.worker_class_name = worker_class_name
        self.job_method = job_method
        self.threads = opts.fetch(:threads, 1)
        self.criteria = opts[:only]
      end
      
      def exchange_name
        "#{worker_class_name}_#{job_method}".downcase
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

      # TODO: want to recognize increases and decreases in numbers of
      # threads and make minimal changes
      def ==(other)
        [worker_class_name, job_method, 
          threads, criteria] ==
        [other.worker_class_name, other.job_method,
          other.threads, other.criteria]
      end

    end

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
