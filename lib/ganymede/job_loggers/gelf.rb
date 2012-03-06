require 'gelf'

class Workling::JobLoggers::GELF < Workling::JobLoggers::Text

  def initialize(*args)
    @logger = ::GELF::Logger.new(*args)
    @logger.level = :info
  end

end
