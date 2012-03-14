require 'woodhouse/job'

class Woodhouse::WorkerProcess
  include Woodhouse::Util
  include Celluloid

  def initialize(worker, config)
    @worker = worker
    @config = config
    puts "starting #{@worker.inspect} worker"
    subscribe!
  end

  def spin_down
    raise NotImplementedError, "implement #spin_down in a subclass of Woodhouse::WorkerProcess"
  end

  private

  def subscribe
    raise NotImplementedError, "implement #subscribe in a subclass of Woodhouse::WorkerProcess"
  end
  
  def can_service_job?(job)
    @worker.criteria.matches?(job.arguments)
  end

  def service_job(job)
    Woodhouse::JobExecution.new(@config, job).execute 
  end

end
