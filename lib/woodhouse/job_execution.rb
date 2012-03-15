class Woodhouse::JobExecution

  def initialize(config, job)
    @config = config
    @job = job
  end

  def execute
    worker = @config.registry[@job.worker_class_name]
    unless worker
      raise Woodhouse::WorkerNotFoundError, "couldn't find job class #{@job.worker_class_name}"
    end
    work_object = worker.new
    # TODO: want to do this kind of stuff through middleware
    if work_object.respond_to?(:logger=)
      work_object.logger = @config.logger
    end
    @config.runner_middleware.call(@job, work_object) {|job, work_object|
      work_object.send(job.job_method, job.arguments)
    }
  end

end
