# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ganymede/version"

Gem::Specification.new do |s|
  s.name        = "ganymede"
  s.version     = Ganymede::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "ganymede"

  s.add_dependency 'fiber18'
  s.add_dependency 'celluloid'

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
