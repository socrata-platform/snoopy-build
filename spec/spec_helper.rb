# Encoding: UTF-8

require 'chef'
require 'chefspec'
require 'chefspec/berkshelf'
require 'simplecov'
require 'simplecov-console'
require 'coveralls'
require_relative 'support/libraries/matchers'
require_relative '../libraries/helpers'
require_relative '../libraries/helpers_builder'

RSpec.configure do |c|
  c.color = true
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
)
SimpleCov.minimum_coverage(100)
SimpleCov.start

at_exit { ChefSpec::Coverage.report! }
