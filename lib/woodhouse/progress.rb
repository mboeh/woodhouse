require 'woodhouse'
require 'json'
require 'digest/sha1'

module Woodhouse::Progress

  class << self

    attr_accessor :client

    def install!
      self.client = Woodhouse::Progress::BunnyProgressClient
      Woodhouse.configure do |config|
        config.runner_middleware << Woodhouse::Progress::InjectProgress
      end
    end

    def pull(job_id)
      client.new(Woodhouse.global_configuration).pull(job_id)
    end

    def pull_raw(job_id)
      client.new(Woodhouse.global_configuration).pull_raw(job_id)
    end

  end

  class ProgressClient
    attr_accessor :config

    def initialize(config)
      self.config = config
    end

    def pull(job_id)
      progress = pull_raw(job_id)
      if progress
        JSON.parse(progress)
      end
    end

    def pull_raw(job_id)
      pull_progress(job_id)
    end

    protected

    def pull_progress(job_id)
      raise NotImplementedError
    end

  end

  class BunnyProgressClient < ProgressClient
    
    protected

    def pull_progress(job_id)
      bunny = Bunny.new(config.server_info)
      
      bunny.start
      begin
        channel = bunny.create_channel
        exchange = channel.direct("woodhouse.progress")
        queue = channel.queue(job_id, :durable => true)
        queue.bind(exchange, :routing_key => job_id)
        _, _, payload = queue.pop
        payload
      ensure
        bunny.stop
      end
    end

  end


  class StatusTicker
    attr_accessor :top
    attr_accessor :current
    attr_accessor :status

    def initialize(job, name, keyw = {})
      self.job  = job
      self.name = name
      self.top  = keyw[:top]
      self.current = keyw.fetch(:start, 0)
      self.status = keyw[:status]
    end

    def to_hash
      { name => count_attributes.merge( "status" => status ) }
    end

    def count_attributes
      { "current" => current }.tap do |h|
        h["top"] = top if top
      end
    end

    def tick(keyw = {})
      status = keyw[:status]
      count  = keyw[:count]
      by     = keyw[:by] || 1
      new_top = keyw[:top]

      if status
        self.status = status
      end
      
      if current
        next_tick = count || current + by

        self.current = next_tick
      end

      self.top = new_top if new_top

      job.update_progress(to_hash)
    end

    alias call tick

    protected

    attr_accessor :job, :name

  end
  
  module JobWithProgress
    
    attr_accessor :progress_sink

    def status_ticker(name, keyw = {})
      StatusTicker.new(self, name, keyw)
    end

    def update_progress(data)
      progress_sink.update_job(self, data)
    end

    def progress_sink
      @progress_sink ||= Woodhouse
    end

  end

  class InjectProgress < Woodhouse::Middleware
    
    def call(job, worker)
      job.extend JobWithProgress
      yield job, worker
    end

  end

end
