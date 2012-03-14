class Woodhouse::Runners::HotBunniesRunner < Woodhouse::Runner
  begin
    require 'hot_bunnies'
  rescue LoadError => err
    define_method(:initialize) {|*args|
      raise err
    }
  end

  def subscribe
    client = HotBunnies.connect(@config.server_info)
    channel = client.create_channel
    channel.prefetch = 1
    queue = channel.queue('')
    exchange = channel.exchange(@worker.exchange_name, :type => :headers)
    queue.bind(exchange, :arguments => @worker.criteria.amqp_headers)
    queue.subscribe(:ack => true).each(:blocking => false) do |headers, msg|
      job = make_job(headers)
      if can_service_job?(job)
        headers.ack
        service_job(job)
      else
        headers.reject
      end
    end
    wait :spin_down
  end

  def spin_down
    signal :spin_down
  end

  private

  def make_job(headers)
    Woodhouse::Job.new(@worker.worker_class_name, @worker.job_method) do |job|
      job.arguments = headers
    end
  end

end
