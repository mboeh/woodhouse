class Woodhouse::JobExecution

  class << self
    attr_accessor :fatal_error_proc
  end

  memory_error_rx = /((OutOf|NoMemory)Error|Java heap space)/
  self.fatal_error_proc = lambda do |err|
    err.name =~ memory_error_rx or err.message =~ memory_error_rx
  end
  
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
        work_object.send(job.job_method, job)
      }
      return true
    rescue Woodhouse::FatalError
      raise
    rescue => err
      if fatal_error?(err)
        raise err
      else
        # Ignore the exception
        return false
      end
    end
  end

  private

  # TODO: lots of similar methods scattered around. Should refactor.
  def symbolize_keys(hash)
    hash.inject({}) {|h,(k,v)|
      h[k.to_sym] = v
      h
    }
  end

  def fatal_error?(err)
    self.class.fatal_error_proc.call(err)
  end

end
