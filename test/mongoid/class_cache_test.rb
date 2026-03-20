require 'test_helper'

module Mongoid
  class ClassCacheTest < BaseTest
    def test_should_resolve_explicit_class
      cache = Mongoid::FixtureKit::ClassCache.new(users: User)
      assert_equal(User, cache['users'])
    end

    def test_should_auto_resolve_from_fixture_name
      cache = Mongoid::FixtureKit::ClassCache.new({})
      assert_equal(User, cache['users'])
    end

    def test_should_return_nil_for_non_mongoid_class
      cache = Mongoid::FixtureKit::ClassCache.new(strings: String)
      assert_nil(cache['strings'])
    end

    def test_should_return_nil_for_unknown_class
      cache = Mongoid::FixtureKit::ClassCache.new({})
      assert_nil(cache['nonexistent_models'])
    end

    def test_should_filter_non_mongoid_classes_on_init
      cache = Mongoid::FixtureKit::ClassCache.new(users: User, strings: String)
      assert_equal(User, cache['users'])
      assert_nil(cache['strings'])
    end
  end
end
