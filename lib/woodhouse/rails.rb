if defined?(Rails::Railtie)
  module Woodhouse::RailsExtensions
    def layout(&blk)
      unless @delay_finished
        @delayed_layout = blk
      else
        super
      end
    end

    def finish_loading_layout!
      @delay_finished = true
      if @delayed_layout
        layout &@delayed_layout
      end
    end
  end

  Woodhouse.extend Woodhouse::RailsExtensions
 
  class Woodhouse::Rails < Rails::Engine
    initializer 'woodhouse-defaults', before: :load_config_initializers do
      # Legacy config file just containing AMQP information.
      legacy_config_path = Rails.root.join("config/workling.yml")
      # New config file containing any configuration options.
      config_path = Rails.root.join("config/woodhouse.yml")
      
      # Preload everything in app/workers so default layout includes them 
      Rails.root.join("app/workers").tap do |workers|
        Pathname.glob(workers.join("**/*.rb")).each do |worker_path|
          worker_path.relative_path_from(workers).basename(".rb").to_s.camelize.constantize
        end
      end

      # Set up reasonable defaults
      Woodhouse.configure do |config|
        config.logger = ::Rails.logger

        config.load_yaml legacy_config_path, section: "server_info", environment: ::Rails.env
        config.load_yaml config_path, environment: ::Rails.env
      end
    end

    initializer "woodhouse-layout" do
      Woodhouse.finish_loading_layout!
    end
  end
end
