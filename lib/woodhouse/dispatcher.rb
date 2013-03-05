class Woodhouse::Dispatcher

  def initialize(config, opts = {}, &blk)
    @config = config
    after_initialize(config, opts = {}, &blk)
  end

  def dispatch(class_name, job_method, arguments)
    dispatch_job Woodhouse::Job.new(class_name, job_method, arguments)
  end

  def dispatch_job(job)
    @config.dispatcher_middleware.call(job) {|job|
      deliver_job(job)
    }
    job
  end

  def update_job(job, data = {})
    deliver_job_update(job, data)
  end

  private

  def after_initialize(config, opts = {}, &blk)

  end

  def deliver_job(job)
    raise NotImplementedError, "implement #deliver_job in a subclass of Woodhouse::Dispatcher"
  end

  def deliver_job_update(job, data)
    raise NotImplementedError, "implement #deliver_job_update in a subclass of Woodhouse::Dispatcher"
  end

end
