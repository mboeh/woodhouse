class Ganymede::Scheduler
  include Ganymede::Util
  include Celluloid

  class SpunDown < StandardError

  end

  class WorkerSet
    include Ganymede::Util
    include Celluloid

    attr_reader :worker

    def initialize(worker, config)
      expect_arg_or_nil :worker, Ganymede::Layout::Worker, worker
      @worker_def = worker
      @config = config
      @threads = []
      spin_up
    end

    def spin_down
      @spinning_down = true
      @threads.each do |thread|
        thread.spin_down
      end
      signal :spun_down
    end

    def wait_until_done
      wait :spun_down
    end

    private

    def spin_up
      @worker_def.threads.times do
        @threads << @config.worker_type.new_link(@worker_def, @config)
      end
    end

  end

  def initialize(config)
    @config = config
    @worker_sets = {}
  end

  def start_worker(worker)
    @worker_sets[worker] = WorkerSet.new_link(worker, @config) unless @worker_sets.has_key?(worker)
  end

  def stop_worker(worker, wait = false)
    if set = @worker_sets[worker]
      wait ? set.spin_down : set.spin_down!
    end
  end
  
  def running_worker?(worker)
    @worker_sets.has_key?(worker)
  end

  def spin_down
    @spinning_down = true
    @worker_sets.each do |worker, set|
      set.spin_down!
    end
    @worker_sets.keys.each do |worker|
      set = @worker_sets[worker]
      set.wait_until_done
      @worker_sets.delete(worker)
    end
  end

end
