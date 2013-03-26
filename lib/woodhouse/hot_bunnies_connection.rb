class Woodhouse::HotBunniesConnection
  attr_reader :client, :server_info

  class Channel
    attr_accessor :amqp

    def initialize(amqp_channel)
      self.amqp = amqp_channel
    end

    def enable_prefetch
      amqp.prefetch = 1
    end

    def worker_queue(worker)
      WorkerQueue.new(amqp, worker)
    end

    def job_queue(job)
      WorkerQueue.new(amqp, job)
    end

    def progress_queue(job)
      ProgressQueue.new(amqp, job)
    end

  end

  class WorkerQueue
    attr_accessor :amqp, :worker

    def initialize(channel, worker)
      self.amqp   = channel
      self.worker = worker
    end

    def queue
      amqp.queue(worker.queue_name)
    end

    def exchange
      amqp.exchange(worker.exchange_name, type: :headers)
    end

    def bind
      queue.bind exchange, arguments: worker.criteria.amqp_headers
      self
    end

    def subscribe
      bind
      queue.subscribe(ack: true).each(blocking: false) do |message, payload|
        yield JobMessage.new(amqp, worker, message, payload)
      end
    end

    def publish(job)
      exchange.publish(job.payload, properties: { headers: job.arguments })
    end

  end

  class JobMessage
    attr_accessor :amqp, :worker, :message, :payload

    def initialize(amqp, worker, message, payload)
      self.amqp    = amqp
      self.worker  = worker
      self.message = message
      self.payload = payload
    end

    def woodhouse_job
      Woodhouse::Job.new(worker.worker_class_name, worker.job_method) do |job|
        job.arguments = message.properties.headers.inject({}) {|h,(k,v)|
          h[k.to_s] = v.to_s
          h
        }
        job.payload = payload
      end
    end

    def ack
      message.ack
    end

    def reject
      message.reject
    end

  end

  # FIXME: Extensions should be able to push stuff like this into connections
  # without their having to be built in and without excessive monkeypatching.
  #
  # I really wish Bunny/HotBunnies had compatible APIs.
  class ProgressQueue
    attr_accessor :amqp, :job

    def initialize(channel, job)
      self.amqp    = channel
      self.job     = job
    end

    def queue
      amqp.queue(job.job_id, Woodhouse::Extension::Progress.queue_options)
    end

    def exchange
      amqp.exchange('woodhouse.progress', type: :direct)
    end

    def bind
      queue.bind(exchange, routing_key: job.job_id)
      self
    end

    def publish(data)
      bind
      exchange.publish(data.to_json, routing_key: job.job_id)
    end

    def fetch
      bind
      payload = nil
      queue.message_count.times do
        _, _, next_payload = queue.pop
        payload = next_payload if next_payload
      end
      payload
    end

  end

  def initialize(server_info)
    @server_info = server_info
  end

  def connect(&blk)
    @client = HotBunnies.connect(server_info)
    
    if blk
      begin
        yield self
      ensure
        disconnect
      end
    end
  end

  def open_channel
    channel = client.create_channel
    yield Channel.new(channel)
  ensure
    channel.close if channel
  end

  def disconnect
    @client.close if client
  ensure
    @client = nil
  end

end
