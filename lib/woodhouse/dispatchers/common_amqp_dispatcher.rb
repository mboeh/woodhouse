# Provides common behavior shared by the Bunny and HotBunnies dispatchers.
class Woodhouse::Dispatchers::CommonAmqpDispatcher < Woodhouse::Dispatcher

  private

  # Yields an AMQP channel to the block, doing any error handling or synchronization
  # necessary.
  def run(&blk)
    raise NotImplementedError
  end

  def deliver_job(job)
    run do |client|  
      exchange = client.exchange(job.exchange_name, :type => :headers)
      publish_job(job, exchange)
    end
  end

  def deliver_job_update(job, data)
    run do |client|
      exchange = client.exchange("woodhouse.progress", :type => :direct)
      client.queue(job.job_id, :arguments => {"x-expires" => 5*60*1000}).bind(exchange, :routing_key => job.job_id)
      exchange.publish(data.to_json, :routing_key => job.job_id)
    end
  end

end
