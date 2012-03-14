class Woodhouse::JobLoggers::Text

  def initialize(logpath, level = Logger::INFO)
    if logpath.kind_of?(String)
      @logger = Logger.new(logpath)
    else
      @logger = logpath
    end
    @logger.level = level
    @logger.formatter = Logger::Formatter.new
  end

  def log(job_ident, status, metadata)
    metadata = metadata.dup
    metadata.delete :_exception
    @logger.info "#{job_ident} (#{status}): #{metadata.inspect}"
  end

end
