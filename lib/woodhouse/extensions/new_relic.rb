require 'woodhouse'

module Woodhouse::NewRelic
  
  class << self

    def install_extension(configuration, opts = {}, &blk)
      require 'woodhouse/extensions/new_relic/instrumentation_middleware'
      configuration.runner_middleware << Woodhouse::NewRelic::InstrumentationMiddleware
      configuration.at(:server_start) do
        ::NewRelic::Agent.manual_start
        configuration.logger.info "New Relic agent started."
      end
      configuration.at(:server_end) do
        ::NewRelic::Agent.shutdown
        configuration.logger.info "New Relic agent shut down."
      end
    end
  end

end

Woodhouse::Extension.register :new_relic, Woodhouse::NewRelic
