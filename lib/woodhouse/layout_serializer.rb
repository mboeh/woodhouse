require 'json'

class Woodhouse::LayoutSerializer

  def initialize(layout)
    @layout = layout
  end

  def as_hash
    { 
      :nodes => node_list(layout.nodes)
    }
  end

  def to_json
    as_hash.to_json
  end

  def self.dump(layout)
    new(layout).to_json
  end

  def self.load(json)
    LayoutLoader.new(json).layout
  end

  class LayoutLoader

    def initialize(json)
      @entries = JSON.parse(json)
    end

    def layout
      Woodhouse::Layout.new.tap do |layout|
        @entries['nodes'].each do |node|
          new_node = layout.add_node(node['name'])
          node['workers'].each do |worker|
            new_node.add_worker Woodhouse::Layout::Worker.new(worker['worker_class_name'], worker['job_method'], :threads => worker['threads'], :only => worker['criteria'])
          end
        end
      end
    end

  end

  private

  attr_reader :layout

  def node_list(nodes)
    nodes.map{|node|
      node_hash(node)
    }
  end

  def node_hash(node)
    {
      :name => node.name,
      :workers => worker_list(node.workers)
    }
  end

  def worker_list(workers)
    workers.map{|worker|
      worker_hash(worker)
    }
  end

  def worker_hash(worker)
    {
      :worker_class_name => worker.worker_class_name,
      :job_method        => worker.job_method,
      :threads           => worker.threads,
      :criteria          => criteria_hash(worker.criteria)
    }
  end

  def criteria_hash(criteria)
    criteria.criteria
  end

end
