# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "woodhouse/version"

Gem::Specification.new do |s|
  s.name        = "woodhouse"
  s.version     = Woodhouse::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew Boeh"]
  s.email       = ["matt@crowdcompass.com", "matthew.boeh@gmail.com"]
  s.homepage    = "http://github.com/mboeh/woodhouse"
  s.summary     = %q{An AMQP-based background worker system for Ruby}
  s.description = %q{An AMQP-based background worker system for Ruby designed to make managing heterogenous tasks relatively easy.
  
  The use case for Woodhouse is for reliable and sane performance in situations where jobs on a single queue may vary significantly in length. The goal is to permit large numbers of quick jobs to be serviced even when many slow jobs are in the queue. A secondary goal is to provide a sane way for jobs on a given queue to be given special priority or dispatched to a server more suited to them.
  
  Clients (i.e., your application) may be using either Ruby 1.9 in any VM.}

  s.rubyforge_project = "woodhouse"

  s.add_dependency 'celluloid', '~> 0.15'
  s.add_dependency 'bunny', "~> 0.9.0.pre4"
  s.add_dependency 'connection_pool', '~> 2.0.0'
  s.add_dependency 'json'
  s.add_dependency 'cause'

  s.add_development_dependency 'rspec', '~> 1.3.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'mocha'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
