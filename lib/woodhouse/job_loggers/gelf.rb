require 'gelf'

class Woodhouse::JobLoggers::GELF < Woodhouse::JobLoggers::Text

  def initialize(*args)
    @logger = ::GELF::Logger.new(*args)
    @logger.level = :info
  end

end
