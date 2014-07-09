class Woodhouse::Scheduler
  include Woodhouse::Util
  include Celluloid

  class SpunDown < StandardError

  end

  class WorkerSet
    include Woodhouse::Util
    include Celluloid

    attr_reader :worker
    trap_exit :worker_died

    def initialize(scheduler, worker, config)
      expect_arg_or_nil :worker, Woodhouse::Layout::Worker, worker
      @scheduler = scheduler
      @worker_def = worker
      @config = config
      @threads = []
      spin_up
    end

    def spin_down
      @spinning_down = true
      @threads.each_with_index do |thread, idx|
        @config.logger.debug "Spinning down thread #{idx} for worker #{@worker_def.describe}"
        thread.spin_down
        thread.terminate
      end
      @scheduler.remove_worker(@worker_def)
      signal :spun_down
    end

    def wait_until_done
      wait :spun_down
    end

    private

    def worker_died(actor, reason)
      if reason
        @config.logger.info "Worker died (#{reason.class}: #{reason.message}). Spinning down."
        @threads.delete actor
        raise Woodhouse::BailOut
      end
    end

    def spin_up
      @worker_def.threads.times do |idx|
        @config.logger.debug "Spinning up thread #{idx} for worker #{@worker_def.describe}"
        worker = @config.runner_type.new_link(@worker_def, @config)
        @threads << worker
        worker.async.subscribe
      end
    end

  end

  trap_exit :worker_set_died

  def initialize(config)
    @config = config
    @worker_sets = {}
  end

  def start_worker(worker)
    @config.logger.debug "Starting worker #{worker.describe}"
    unless @worker_sets.has_key?(worker)
      @worker_sets[worker] = WorkerSet.new_link(Celluloid.current_actor, worker, @config)
      true
    else
      false
    end
  end

  def stop_worker(worker, wait = false)
    if set = @worker_sets[worker]
      @config.logger.debug "Spinning down worker #{worker.describe}"
      set.spin_down
    end
  end
  
  def running_worker?(worker)
    @worker_sets.has_key?(worker)
  end

  def spin_down
    @spinning_down = true
    @config.logger.debug "Spinning down all workers"
    @worker_sets.each do |worker, set|
      set.spin_down
      set.terminate
    end
  end

  def remove_worker(worker)
    @worker_sets.delete(worker)
  end

  def worker_set_died(actor, reason)
    if reason
      @config.logger.info "Worker set died (#{reason.class}: #{reason.message}). Spinning down."
      begin
        spin_down
      ensure
        raise reason
      end
    end
  end

end
