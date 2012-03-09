class Ganymede::Scheduler
  include Ganymede::Util
  include Celluloid

  trap_exit :worker_set_finished

  class SpunDown < StandardError

  end

  class WorkerSet
    include Ganymede::Util
    include Celluloid

    attr_reader :worker

    def initialize(worker)
      expect_arg_or_nil :worker, Ganymede::Layout::Worker, worker
      @worker_def = worker
      @threads = []
    end

    def spin_down
      @spinning_down = true
      @threads.each do |thread|
        thread.spin_down
      end
      check_if_done
    end

    private

    def check_if_done
      if @spinning_down and @threads.empty?
        raise SpunDown
      end
    end

  end

  def initialize(registry)
    @registry = registry
    @worker_sets = {}
  end

  def start_worker(worker)
    @worker_sets[worker] = WorkerSet.new_link(worker) unless @worker_sets.has_key?(worker)
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
    check_if_done
    wait :done
  end

  def worker_set_finished(actor, reason)
    if reason.kind_of? SpunDown
      @worker_sets.delete_if{|k,v| v == actor}
      check_if_done
    else
      # TODO: worker set bombed out. You fixulate this!
      raise reason
    end
  end

  private

  def check_if_done
    if @spinning_down and @worker_sets.empty?
      signal :done
    end
  end

end
