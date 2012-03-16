class Woodhouse::JobExecution

  def initialize(config, job)
    @config = config
    @job = job
  end

  # Looks up the correct worker class for a job and executes it, running it
  # through the runner middleware stack first. Returns true if the job finishes
  # without an exception, false otherwise.
  #
  # If you need to keep track of exceptions raised by jobs, add middleware to
  # handle them, like Woodhouse::Middleware::AirbrakeExceptions.
  def execute
    worker = @config.registry[@job.worker_class_name]
    unless worker
      raise Woodhouse::WorkerNotFoundError, "couldn't find job class #{@job.worker_class_name}"
    end
    work_object = worker.new
    begin
      @config.runner_middleware.call(@job, work_object) {|job, work_object|
        work_object.send(job.job_method, job.arguments)
      }
      return true
    rescue => err
      # Ignore the exception
      return false
    end
  end

end
