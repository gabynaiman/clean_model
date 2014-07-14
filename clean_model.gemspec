# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clean_model/version'

Gem::Specification.new do |spec|
  spec.name        = 'clean_model'
  spec.version     = CleanModel::VERSION
  spec.authors     = ['Gabriel Naiman']
  spec.email       = ['gabynaiman@gmail.com']
  spec.homepage    = 'https://github.com/gabynaiman/clean_model'
  spec.summary     = 'Extensions for ActiveModel to implement multiple types of models'
  spec.description = 'Extensions for ActiveModel to implement multiple types of models'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '~> 3.2'
  spec.add_dependency 'web_client', '0.0.5'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '2.13.0'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
end
