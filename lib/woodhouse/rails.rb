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
    config.autoload_paths << Rails.root.join("app/workers")

    initializer 'woodhouse' do
      config_paths = %w[woodhouse.yml workling.yml].map{|file|
        Rails.root.join("config/" + file)
      }
      # Preload everything in app/workers so default layout includes them 
      Rails.root.join("app/workers").tap do |workers|
        Pathname.glob(workers.join("**/*.rb")).each do |worker_path|
          worker_path.relative_path_from(workers).basename(".rb").to_s.camelize.constantize
        end
      end
      # Set up reasonable defaults
      Woodhouse.configure do |config|
        config.logger = ::Rails.logger
        if ::Rails.env =~ /^(development|test)$/
          config.dispatcher_type = :local
        else
          config.dispatcher_type = :bunny
        end
        config_paths.each do |path|
          if File.exist?(path)
            config.server_info = YAML.load(File.read(path))[::Rails.env]
          end
        end
      end
      Woodhouse.finish_loading_layout!
    end
  end
end
