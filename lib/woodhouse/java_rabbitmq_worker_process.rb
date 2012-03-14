class Woodhouse::JavaRabbitMQWorkerProcess < Woodhouse::WorkerProcess
  begin
    require 'rabbitmq_client'
  rescue LoadError => err
    define_method(:initialize) {|*|
      raise err.class, err.message + " (deferred until class was used)"
    }
  end

  def subscribe
    client = RabbitMQClient.new(@config.server_info)
    client.channel.basicQos(1)
    # rabbitmq-client doesn't support unnamed queues yet
    queue = client.queue(@worker.exchange_name + "-" + rand(10_000_000).to_s)
    exchange = client.exchange(@worker.exchange_name, :type => :headers)
    queue.bind(exchange, :arguments => @worker.criteria.amqp_headers)
    queue.subscribe do |message|
      break if @stopped
    end
  ensure
    client.disconnect if client.connected?
  end

end
