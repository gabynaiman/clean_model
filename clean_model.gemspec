# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'clean_model/version'

Gem::Specification.new do |s|
  s.name        = 'clean_model'
  s.version     = CleanModel::VERSION
  s.authors     = ['Gabriel Naiman']
  s.email       = ['gabynaiman@gmail.com']
  s.homepage    = 'https://github.com/gabynaiman/clean_model'
  s.summary     = 'Extensions for ActiveModel to implement multiple types of models'
  s.description = 'Extensions for ActiveModel to implement multiple types of models'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'activemodel', '>= 3.0.0'
  s.add_dependency 'web_client', '0.0.3'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
end
