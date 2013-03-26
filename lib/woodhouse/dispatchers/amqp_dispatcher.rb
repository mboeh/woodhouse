class Woodhouse::Dispatchers::AmqpDispatcher

  private
  
  def connection
    @config.amqp_connection
  end

  def deliver_job(job)
    connection.connect do |channel|
      channel.job_queue(job).publish(job)
    end
  end

  def deliver_job_update(job, data)
    connection.connect do |channel|
      channel.progress_queue(job).publish(data)
    end
  end

end
