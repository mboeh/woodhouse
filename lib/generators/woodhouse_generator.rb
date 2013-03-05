class WoodhouseGenerator < Rails::Generators::Base
  desc "Creates initializer and script files for Woodhouse."

  def create_initializer
    initializer "woodhouse.rb", <<-EOF
Woodhouse.configure do |woodhouse|
  # woodhouse.dispatcher_type = :amqp
  # woodhouse.extension :progress
  # woodhouse.extension :new_relic
end

Woodhouse.layout do |layout|
  layout.node(:default) do |node|
    node.all_workers
  end
end
    EOF
  end

  def create_script
    create_file "script/woodhouse", <<-EOF
#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

logg = Logger.new(File.dirname(__FILE__) + "/../log/woodhouse.log")
logg.level = Logger::DEBUG
logg.formatter = Logger::Formatter.new

Celluloid.logger = logg
Woodhouse.global_configuration.logger = logg

Woodhouse.global_configuration.dispatcher_type = :amqp

Woodhouse::Process.new.execute
    EOF
  end

end
