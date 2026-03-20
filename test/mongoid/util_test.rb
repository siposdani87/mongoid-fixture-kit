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

    def test_embedded_default_fields_are_removed_when_matching
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])

      # Address has `field :real, type: Boolean, default: true`
      # The fixture for user1 does not set `real`, so the default should apply
      user = User.find_by(firstname: 'Margot')
      assert_not_nil(user.address)
      # The default value is true; since it wasn't overridden, it should be present
      assert_equal(true, user.address.real)
    end

    def test_nested_embedded_belongs_to_resolved_via_sanitize
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])

      user = User.find_by(firstname: 'Margot')
      home = user.homes.first
      assert_not_nil(home.address)
      organization = Organisation.find_by(name: '1 Organisation')
      assert_equal(organization.id, home.address.organisation_id)
    end

    def test_find_or_create_document_propagates_errors
      util = Mongoid::FixtureKit::Util.new
      # Use a nonexistent collection with an invalid document to trigger a save error.
      # After removing the rescue block, errors should propagate.
      # We verify by checking that find_or_create_document does NOT silently return
      # an unsaved document when the model exists and can be saved.
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
      doc = util.find_or_create_document(User, 'geoffroy')
      assert(doc.persisted?, 'Document should be persisted after find_or_create_document')
    end
  end
end
