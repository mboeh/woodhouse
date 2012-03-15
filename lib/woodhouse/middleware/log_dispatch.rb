class Woodhouse::Middleware::LogDispatch < Woodhouse::Middleware
  
  def call(job)
    begin
      yield job
    rescue => err
      log "#{job.describe} could not be dispatched: #{err.inspect}"
      raise err
    end
    log "#{job.describe} dispatched"
  end

  private

  def log(msg)
    if @config.logger
      @config.logger.info msg
    end
  end

end
