# A dispatcher which simply swallows and stores jobs without performing them. This
# is to be used in testing other applications' interactions with Woodhouse.
class Woodhouse::Dispatchers::TestDispatcher < Woodhouse::Dispatcher

  # All jobs (Woodhouse::Job) which have been dispatched since this dispatcher was last cleared.
  attr_reader :jobs
  # All job updates (used in the Progress extension) which have been dispatched since this dispatcher was last cleared.
  attr_reader :job_updates
  
  # Wipe out all stored jobs and job updates.
  def clear!
    jobs.clear
    job_updates.clear
  end

  private

  def after_initialize(*)
    @jobs = []
    @job_updates = []
  end

  def deliver_job(job)
    @jobs << job
  end

  def deliver_job_update(job, data)
    @job_updates << [job, data]
  end

end
