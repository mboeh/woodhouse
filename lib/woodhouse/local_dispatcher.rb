class Woodhouse::LocalDispatcher < Woodhouse::Dispatcher

  def dispatch_job(job)
    Woodhouse::JobExecution.new(@config, job).execute 
  end

end
