#
# The abstract base class for actors in charge of finding and running jobs
# of a given type. Runners will be allocated for each Woodhouse::Layout::Worker
# in a layout. Woodhouse::Layout::Worker#threads indicates how many Runners should
# be spawned for each job type.
#
# The lifecycle of a Runner is to be created by Woodhouse::Scheduler::WorkerSet,
# and to automatically begin subscribing as soon as it is initialized. At some
# point, the actor will receive the +spin_down+ message, at which case it must
# cease all work and return from +subscribe+.
#
# Whenever a Runner receives a job on its queue, it should convert it into a 
# Workling::Job and pass it to +service_job+ after confirming with
# +can_service_job?+ that this is an appropriate job for this queue.
#
# Runners should always subscribe to queues in ack mode. Messages should be
# acked after they finish, and rejected if the job is inappropriate for this
# worker or if it raises an exception.
#
# TODO: document in more detail the contract between Runner and Dispatcher over
# AMQP exchanges, and how Woodhouse uses AMQP to distribute jobs.
#
class Woodhouse::Runner
  include Woodhouse::Util
  include Celluloid

  def initialize(worker, config)
    @worker = worker
    @config = config
    @config.logger.debug "Thread for #{@worker.describe} ready and waiting for jobs"
    subscribe!
  end

  # Implement this in a subclass. When this message is received by an actor, it should
  # finish whatever job it is currently doing, gracefully disconnect from AMQP, and
  # stop the subscribe loop.
  def spin_down
    raise NotImplementedError, "implement #spin_down in a subclass of Woodhouse::Runner"
  end

  private

  # Implement this in a subclass. When this message is received by an actor, it should
  # connect to AMQP and start pulling jobs off the queue. This method should not finish
  # until spin_down is called.
  def subscribe # :doc:
    raise NotImplementedError, "implement #subscribe in a subclass of Woodhouse::Runner"
  end
  
  # Returns +true+ if the Job's arguments match this worker's QueueCriteria, else +false+.
  def can_service_job?(job) # :doc:
    @worker.criteria.matches?(job.arguments)
  end

  # Executes a Job. See Woodhouse::JobExecution.
  def service_job(job) # :doc:
    @config.logger.debug "Servicing job for #{@worker.describe}"
    Woodhouse::JobExecution.new(@config, job).execute 
  end

end
