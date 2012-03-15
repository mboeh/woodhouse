class Woodhouse::Dispatchers::LocalDispatcher < Woodhouse::Dispatcher

  private

  def deliver_job(job)
    Woodhouse::JobExecution.new(@config, job).execute 
  end

end
