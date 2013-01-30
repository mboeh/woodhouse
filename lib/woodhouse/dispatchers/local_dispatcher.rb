class Woodhouse::Dispatchers::LocalDispatcher < Woodhouse::Dispatcher

  private

  def deliver_job(job)
    Woodhouse::JobExecution.new(@config, job).execute 
  end

  def deliver_job_update(job, data)
    
  end

end
