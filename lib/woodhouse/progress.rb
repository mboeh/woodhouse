require 'woodhouse'

module Woodhouse::Progress

  class StatusTicker
    attr_accessor :top
    attr_accessor :current
    attr_accessor :status

    def new(job, name, keyw = {})
      self.job  = job
      self.name = name
      self.top  = keyw[:top]
      self.current = keyw[:start]
      self.status = keyw[:status]
    end

    def to_hash
      { name => {
        "top"     => top,
        "current" => current,
        "status"  => status,
      }}
    end

    def tick!(status = nil, keyw = nil)
      keyw ||= status
      self.status = status if status

      next_tick = keyw[:count] || current + (keyw[:by] || 1)

      self.current = next_tick

      job.update_progress(to_hash)
    end

    alias call tick!

    protected

    attr_accessor :job, :name

  end

  
  module JobWithProgress
    
    def status_ticker(name, keyw = {})
      StatusTicker.new(self, name, keyw)
    end

    def update_progress(data)
      Woodhouse.update_job(self, data)
    end

  end


end
