class Woodhouse::Dispatchers::LocalPoolDispatcher < Woodhouse::Dispatcher

  class Worker
    include Celluloid

    def execute(executor)
      executor.execute
    end
  end

  private

  def after_initialize(config, opts = {}, &blk)
    @pool = Worker.pool(size: opts[:size] || 10)
  end

  def deliver_job(job)
    @pool.async.execute Woodhouse::JobExecution.new(@config, job)
  end

  def deliver_job_update(job, data)
    @config.logger.info "[Woodhouse job update] #{job.job_id} -- #{data.inspect}"
  end

end
