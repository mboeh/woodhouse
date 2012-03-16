class Woodhouse::LayoutBuilder

  attr_reader :layout

  class NodeBuilder
    
    def initialize(config, node)
      @config = config
      @node = node
    end

    def all_workers(options = {})
      @node.default_configuration! @config, options
    end

    def add(class_name, job_method, opts = {})
      if job_method.kind_of?(Hash)
        # Two-argument invocation
        opts = job_method
        job_method = nil
        methods = @config.registry[class_name].public_instance_methods(false)
      else
        methods = [job_method]
      end
      remove(class_name, job_method, opts.empty? ? nil : opts)
      methods.each do |method|
        @node.add_worker Woodhouse::Layout::Worker.new(class_name, method, opts)
      end
    end

    def remove(class_name, job_method = nil, opts = nil)
      @node.workers.select{|worker|
        worker.worker_class_name == class_name &&
          (job_method.nil? || worker.job_method == job_method) &&
          (opts.nil? || worker.criteria.criteria == opts[:only])
      }.each do |worker|
        @node.remove_worker(worker)
      end
    end

  end

  def initialize(config, layout = nil)
    @config = config
    @layout = layout || Woodhouse::Layout.new
    @nodes ||= {}
    yield self if block_given?
  end

  def node(name)
    @layout.node(name) || @layout.add_node(name)
    yield(@nodes[name] ||= NodeBuilder.new(@config, @layout.node(name)))
  end

end
