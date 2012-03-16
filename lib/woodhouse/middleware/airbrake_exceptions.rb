class Woodhouse::Middleware::AirbrakeExceptions < Woodhouse::Middleware

  def call(job, worker)
    begin
      yield job, worker
    rescue => err
      Airbrake.notify(err)
      raise err
    end
  end

end
