require 'test_helper'

module Mongoid
  class UtilTest < BaseTest
    def test_label_interpolation
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      fs = util.create_fixtures('test/fixtures/', %w[schools])

      schools = fs.find { |x| x.model_class == School }
      school0 = schools['school0']
      assert_equal('School 0', school0['name'])
    end

    def test_defaults_key_is_removed
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      fs = util.create_fixtures('test/fixtures_with_defaults', %w[groups])

      groups = fs.find { |x| x.model_class == Group }
      assert_nil(groups['DEFAULTS'])
      assert_not_nil(groups['custom_group'])
    end

    def test_cached_fixtures_returns_empty_when_no_cache
      util = Mongoid::FixtureKit::Util.new
      assert_equal([], util.cached_fixtures)
    end

    def test_fixture_is_cached_returns_nil_for_unknown
      util = Mongoid::FixtureKit::Util.new
      assert_nil(util.fixture_is_cached?('nonexistent'))
    end

    def test_create_fixtures_uses_cache_on_second_call
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache

      fs1 = util.create_fixtures('test/fixtures/', %w[schools])
      fs2 = util.create_fixtures('test/fixtures/', %w[schools])

      assert_equal(fs1.map(&:name), fs2.map(&:name))
    end

    def test_embedded_documents_are_created
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])

      user = User.find_by(firstname: 'Margot')
      assert_not_nil(user.address)
      assert_equal('Strasbourg', user.address.city)
      assert_equal(1, user.homes.count)
      assert_equal('Home', user.homes.first.name)
    end

    def test_nested_embedded_documents
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])

      user = User.find_by(firstname: 'Margot')
      home = user.homes.first
      assert_not_nil(home.address)
      assert_equal('Strasbourg', home.address.city)
    end

    def test_macro_from_relation_handles_modern_mongoid
      util = Mongoid::FixtureKit::Util.new
      relation = User.relations['address']
      macro = util.macro_from_relation(relation)
      assert_equal(:embeds_one, macro)
    end
  end
end
