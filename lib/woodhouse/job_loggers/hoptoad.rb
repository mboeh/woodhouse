class Woodhouse::JobLoggers::Hoptoad

  def initialize

  end

  def log(job_ident, status, metadata)
    if status == "raised exception"
      Airbrake.notify(metadata[:_exception])
    end
  end

end
