require 'bundler/setup'
require 'simplecov'
SimpleCov.configure do
  add_filter '/test/'
end
SimpleCov.start if ENV['COVERAGE']

require 'minitest/autorun'
require 'mongoid'

require File.expand_path("../../lib/mongoid-fixture_kit", __FILE__)

Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml", "test")

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

ActiveSupport::TestCase.test_order = :random

class BaseTest < ActiveSupport::TestCase
  def teardown
    Mongoid::Clients.default.use('mongoid_fixture_kit_test').database.drop
  end
end