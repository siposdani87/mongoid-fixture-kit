require 'test_helper'

class LoadOnceTest < BaseTest
  include Mongoid::FixtureKit::TestHelper

  self.fixture_path = 'test/load_once_fixtures'
  self.load_fixtures_once = true

  class_attribute :count
  self.count = 0

  module FixtureLoadCount
    def count
      LoadOnceTest.count += 1
    end
  end

  Mongoid::FixtureKit.context_class.include(FixtureLoadCount)

  def teardown; end

  def count_equal_one
    assert_equal(1, self.class.count)
    assert_nothing_raised { tests(:test1) }
  end

  5.times do |i|
    alias_method "test_load_once_#{i}", :count_equal_one
  end
end
