if defined?(Rails::Railtie)
  class Woodhouse::Rails < Rails::Railtie
    config.autoload_paths << config.root.join("app/workers")

    initializer 'woodhouse' do
      config_paths = %w[woodhouse.yml workling.yml].map{|file|
        Rails.root.join("config/" + file)
      }
      # Set up reasonable defaults
      Woodhouse.configure do |config|
        config.logger = ::Rails.logger
        if ::Rails.env =~ /development|test/
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
    end
  end
end
