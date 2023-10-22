require 'test_helper'

class FixturesTest < BaseTest
  include Mongoid::FixtureKit::TestHelper
  self.fixture_path = 'test/fixtures'

  def test_should_access_fixtures
    _geoffroy = users(:geoffroy)
    assert(true)
  rescue StandardError => e
    assert(false, e)
  end
end
