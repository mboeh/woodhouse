module Woodhouse::Runners
  
  def self.guess
    if defined? ::JRUBY_VERSION
      Woodhouse::Runners::HotBunniesRunner
    else
      Woodhouse::Runners::BunnyRunner
    end
  end

end

require 'woodhouse/runner'
require 'woodhouse/runners/bunny_runner'
require 'woodhouse/runners/hot_bunnies_runner'
