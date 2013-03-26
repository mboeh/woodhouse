# A generic AMQP runner that relies on a Connection.
class Woodhouse::Runners::AmqpRunner < Woodhouse::Runner

  def subscribe
    @config.amqp_connection.connect do |cx|
      cx.open_channel do |channel|
        channel.enable_prefetch
        channel.worker_queue(@worker).subscribe do |message|
          handle_job message, message.woodhouse_job
        end
      end
      wait :spin_down
    end
  end

  def spin_down
    signal :spin_down
  end

  private

  def bail_out(err)
    raise Woodhouse::BailOut, "#{err.class}: #{err.message}"
  end

  def handle_job(message, job)
    begin
      if can_service_job?(job)
        if service_job(job)
          message.ack
        else
          message.reject
        end
      else
        @config.logger.error("Cannot service job #{job.describe} in queue for #{@worker.describe}")
        message.reject
      end
    rescue => err
      begin
        @config.logger.error("Error bubbled up out of worker. This shouldn't happen. #{err.message}")
        err.backtrace.each do |btr|
          @config.logger.error("  #{btr}")
        end
        message.reject
      ensure
        bail_out(err)
      end
    end
  end

end
