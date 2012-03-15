class Woodhouse::Middleware::AssignLogger < Woodhouse::Middleware

  def call(job, worker)
    if @config.logger and worker.respond_to?(:logger)
      worker.logger = @config.logger
    end
    yield job, worker
  end

end
