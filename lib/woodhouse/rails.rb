if defined?(Rails)
  class Woodhouse::Rails < Rails::Engine
    config.autoload_paths << config.root.join("app/workers")

    initializer 'woodhouse' do
      Woodhouse.global_configuration.logger = ::Rails.logger
    end
  end
end
