require 'woodhouse'

ActiveSupport::Dependencies.autoload_paths << RAILS_ROOT + "/app/workers"

Woodhouse.configure do |config|
  config_paths = %w[woodhouse.yml workling.yml].map{|file|
    RAILS_ROOT + "/config/" + file
  }
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
  config.runner_type = Woodhouse::Runners.guess
end
