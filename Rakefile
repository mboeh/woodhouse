require 'rubygems'
require 'rake'
require 'bundler/setup'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|

end

require 'rdoc/task'
Rake::RDocTask.new(:rdoc) do |t|
  t.main = "README.rdoc"
  t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
