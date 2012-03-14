class Woodhouse::Dispatcher

  def initialize(config)
    @config = config
  end

  def dispatch(class_name, job_method, arguments)
    dispatch_job Woodhouse::Job.new(class_name, job_method, arguments)
  end

  def dispatch_job(job)
    raise NotImplementedError, "implement #dispatch_job in a subclass of Woodhouse::Dispatcher"
  end

end
