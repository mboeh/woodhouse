class Woodhouse::Middleware::LogJobs < Woodhouse::Middleware

  def call(job, worker)
    log "#{job.describe} starting"
    begin
      yield job, worker
    rescue => err
      log "#{job.describe} failed: #{err.inspect}"
      raise err
    end
    log "#{job.describe} done"
  end

  private

  def log(msg)
    if @config.logger
      @config.logger.info msg
    end
  end

end
