require 'test_helper'

class FixturesTest < BaseTest
  include Mongoid::FixtureKit::TestHelper

  self.fixture_path = 'test/fixtures'

  def test_should_access_fixtures
    geoffroy = users(:geoffroy)
    assert_equal('Geoffroy', geoffroy.firstname)
  end

  def test_should_access_fixtures_with_reload
    geoffroy = users(:geoffroy)
    assert_equal('Geoffroy', geoffroy.firstname)

    reloaded = users(:geoffroy, :reload)
    assert_equal('Geoffroy', reloaded.firstname)
  end

  def test_should_raise_fixture_not_found
    assert_raises(Mongoid::FixtureKit::FixtureNotFound) do
      users(:nonexistent_user)
    end
  end

  def test_should_set_timestamps_on_models
    geoffroy = users(:geoffroy)
    assert_not_nil(geoffroy.u_at, 'Updated::Short timestamp should be set')
  end

  def test_should_set_created_timestamps
    util = Mongoid::FixtureKit::Util.new
    util.reset_cache
    util.create_fixtures('test/fixtures/', %w[users groups schools organisations])

    group = Group.find_by(name: 'Sudoers!')
    assert_not_nil(group.c_at, 'Created::Short timestamp should be set')

    organisation = Organisation.find_by(name: '1 Organisation')
    assert_not_nil(organisation.created_at, 'Created timestamp should be set')

    school = School.find_by(name: 'School')
    assert_not_nil(school.updated_at, 'Updated timestamp should be set')
  end

  def test_should_access_multiple_fixtures_at_once
    geoffroy, dad = users(:geoffroy, :dad)
    assert_equal('Geoffroy', geoffroy.firstname)
    assert_equal('Dad', dad.firstname)
  end

  def test_teardown_fixtures_resets_cache
    assert_not_empty(self.class.util.cached_fixtures)
    teardown_fixtures
    assert_empty(self.class.util.cached_fixtures)
  end

  def test_fixtures_all_loads_every_yaml_file
    fixture_names = Dir["#{self.class.fixture_path}/{**,*}/*.{yml}"]
    fixture_names.map! { |f| f[(self.class.fixture_path.to_s.length + 1)..-5] }

    assert_includes(fixture_names, 'users')
    assert_includes(fixture_names, 'groups')
    assert_includes(fixture_names, 'schools')
    assert_includes(fixture_names, 'organisations')
    assert_includes(fixture_names, 'not_models')
  end
end
