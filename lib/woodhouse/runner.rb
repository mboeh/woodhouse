class Woodhouse::Runner
  include Woodhouse::Util
  include Celluloid

  def initialize(worker, config)
    @worker = worker
    @config = config
    @config.logger.debug "Thread for #{@worker.describe} ready and waiting for jobs"
    subscribe!
  end

  def spin_down
    raise NotImplementedError, "implement #spin_down in a subclass of Woodhouse::Runner"
  end

  private

  def subscribe
    raise NotImplementedError, "implement #subscribe in a subclass of Woodhouse::Runner"
  end
  
  def can_service_job?(job)
    @worker.criteria.matches?(job.arguments)
  end

  def service_job(job)
    @config.logger.debug "Servicing job for #{@worker.describe}"
    Woodhouse::JobExecution.new(@config, job).execute 
  end

end
