require 'ganymede/job'

class Ganymede::WorkerProcess
  include Ganymede::Util
  include Celluloid

  def initialize(worker, config)
    @worker = worker
    @config = config
    subscribe!
  end

  def spin_down
    raise NotImplementedError, "implement #spin_down in a subclass of Ganymede::WorkerProcess"
  end

  private

  def subscribe
    raise NotImplementedError, "implement #subscribe in a subclass of Ganymede::WorkerProcess"
  end
  
  def can_service_job?(job)
    @worker.criteria.matches?(job.arguments)
  end

  def service_job(job)
    @config.registry[job.worker_class_name].new.send(job.job_method, job.arguments)
  end

end
