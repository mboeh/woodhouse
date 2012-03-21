require 'rubygems'
require 'rake'
require 'bundler/setup'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'spec/rake/spectask'
namespace :spec do
  
  Spec::Rake::SpecTask.new(:server) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"] - FileList["spec/integration/*_spec.rb"]
  end

  Spec::Rake::SpecTask.new(:client) do |t|
    t.spec_files = %w[spec/layout_spec.rb spec/middleware_stack_spec.rb spec/mixin_registry_spec.rb]
  end

end

# Full server specs are supported on Ruby 1.9 or JRuby.
if RUBY_VERSION.to_f >= 1.9 or %w[jruby rbx].include?(RUBY_ENGINE)
  task :spec => "spec:server"
else
  task :spec => "spec:client"
end

task :default => :spec

if ENV['RDOC']
  require 'rdoc/task'
  Rake::RDocTask.new(:rdoc) do |t|
    t.main = "README.rdoc"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  end
end
