class Woodhouse::Middleware

  def initialize(config)
    @config = config
  end

  def call(*args)
    yield *args
  end

end

require 'woodhouse/middleware/log_jobs'
require 'woodhouse/middleware/log_dispatch'
require 'woodhouse/middleware/assign_logger'
