class Woodhouse::JobLoggers::Hydra

  def initialize(*loggers)
    @loggers = loggers.flatten
  end

  def log(job_ident, status, metadata)
    @loggers.each do |logger|
      begin
        logger.log(job_ident, status, metadata)
      rescue Exception => err
      end
    end
  end

end
