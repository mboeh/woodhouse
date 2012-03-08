class Ganymede::Scheduler
  include Ganymede::Util
  include Celluloid

  trap_exit :worker_set_finished

  class SpunDown < StandardError

  end

  class WorkerSet
    include Ganymede::Util
    
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

  def initialize
    @worker_sets = {}
  end

  def start_worker(worker)
    @worker_sets[worker] ||= WorkerSet.new(worker)
  end

  def stop_worker(worker)
    if set = @worker_sets[worker]
      set.spin_down!
    end
  end

  def spin_down
    @spinning_down = true
    @worker_sets.each do |worker, set|
      set.spin_down!
    end
    check_if_done
  end

  protected

  def worker_set_finished(actor, reason)
    if reason == SpunDown
      @worker_sets.delete(actor.worker)
      check_if_done
    else
      # TODO: worker set bombed out. You fixulate this!
      raise reason
    end
  end

  private

  def check_if_done
    if @spinning_down and @worker_sets.empty?
      raise SpunDown
    end
  end

end
