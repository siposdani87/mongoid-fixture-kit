require 'test_helper'

class FixturesTest < BaseTest
  include Mongoid::FixtureKit::TestHelper
  self.fixture_path = 'test/fixtures'

  def test_should_access_fixtures
    begin
      _geoffroy = users(:geoffroy)
      assert true
    rescue StandardError => e
      puts e
      assert false, 'An exception was thrown'
    end
  end
end
