require 'coverage_helper'
require 'webmock/rspec'
require 'clean_model'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
