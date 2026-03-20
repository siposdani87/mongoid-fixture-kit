require 'test_helper'

module Mongoid
  class FixtureTest < BaseTest
    def setup
      @fixture = Mongoid::FixtureKit::Fixture.new('geoffroy', { 'firstname' => 'Geoffroy', 'lastname' => 'Planquart' }, User)
    end

    def test_should_access_attributes_via_brackets
      assert_equal('Geoffroy', @fixture['firstname'])
      assert_equal('Planquart', @fixture['lastname'])
    end

    def test_should_iterate_with_each
      keys = @fixture.map { |k, _v| k }
      assert_includes(keys, 'firstname')
      assert_includes(keys, 'lastname')
    end

    def test_should_return_class_name
      assert_equal('User', @fixture.class_name)
    end

    def test_should_return_nil_class_name_without_model
      fixture = Mongoid::FixtureKit::Fixture.new('test', { 'value' => '1' }, nil)
      assert_nil(fixture.class_name)
    end

    def test_should_raise_fixture_class_not_found_without_model
      fixture = Mongoid::FixtureKit::Fixture.new('test', { 'value' => '1' }, nil)
      assert_raises(Mongoid::FixtureKit::FixtureClassNotFound) do
        fixture.find
      end
    end

    def test_to_hash_returns_fixture_data
      assert_equal({ 'firstname' => 'Geoffroy', 'lastname' => 'Planquart' }, @fixture.to_hash)
    end
  end
end
