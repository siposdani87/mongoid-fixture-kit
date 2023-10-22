require 'bundler/setup'
require 'minitest/reporters'
require 'simplecov'
require 'simplecov_json_formatter'

Minitest::Reporters.use!([Minitest::Reporters::ProgressReporter.new])

SimpleCov.configure do
  add_filter '/test/'
end
SimpleCov.start do
  formatter(SimpleCov::Formatter::JSONFormatter)
end

require 'minitest/autorun'
require 'mongoid'

require File.expand_path('../lib/mongoid_fixture_kit', __dir__)

Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml", 'test')

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

ActiveSupport::TestCase.test_order = :random

class BaseTest < ActiveSupport::TestCase
  def teardown
    Mongoid::Clients.default.use('mongoid_fixture_kit_test').database.drop
  end
end
