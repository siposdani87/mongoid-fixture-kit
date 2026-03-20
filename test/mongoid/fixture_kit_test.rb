require 'test_helper'

module Mongoid
  class FixtureKitTest < BaseTest
    def test_should_initialize_fixture_kit
      fs = Mongoid::FixtureKit.new('users', 'User', 'test/fixtures/users')
      assert_equal(User, fs.model_class)
      fixture = fs['geoffroy']
      assert_equal('User', fixture.class_name)
      assert_equal('Geoffroy', fixture['firstname'])
      assert_equal('Planquart', fixture['lastname'])
    end

    def test_should_not_create_fixtures
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      fs = util.create_fixtures('test/fixtures/', [])
      assert_equal(0, fs.count)
    end

    def test_should_create_not_model_fixture
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      fs = util.create_fixtures('test/fixtures', %w[not_models])
      fs = fs.first
      fixture = fs['error']

      assert_raises(Mongoid::FixtureKit::FixtureClassNotFound) do
        fixture.find
      end
    end

    test 'should raised if nested polymorphic relation' do
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      assert_raises(Mongoid::FixtureKit::FixtureError) do
        util.create_fixtures('test/nested_polymorphic_relation_fixtures', %w[groups])
      end
    end
  end

  class FixtureKitBelongsToTest < BaseTest
    def setup
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
    end

    def test_belongs_to_relation
      geoffroy = User.find_by(firstname: 'Geoffroy')
      sudoers = Group.find_by(name: 'Sudoers!')
      assert(sudoers.main_users.include?(geoffroy))

      user1 = User.find_by(firstname: 'Margot')
      group1 = Group.find_by(name: 'Margot')
      assert_equal(group1, user1.main_group)
    end

    def test_polymorphic_belongs_to_relation
      sudoers = Group.find_by(name: 'Sudoers!')
      organization1 = Organisation.find_by(name: '1 Organisation')
      assert_equal(organization1, sudoers.something)

      school = School.find_by(name: 'School')
      group1 = Group.find_by(name: 'Margot')
      assert_equal(school, group1.something)
    end

    def test_nested_polymorphic_belongs_to
      group = Group.find_by(name: 'Test nested polymorphic belongs_to')
      assert_not_nil(group)
      assert_instance_of(Organisation, group.something)
    end
  end

  class FixtureKitHasManyTest < BaseTest
    def setup
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
    end

    def test_has_many_relation
      geoffroy = User.find_by(firstname: 'Geoffroy')
      test_item = Item.find_by(name: 'Test')
      assert_equal(geoffroy, test_item.user)
    end

    def test_polymorphic_has_many_relation
      school = School.find_by(name: 'School')
      group1 = Group.find_by(name: 'Margot')
      assert_equal(1, school.groups.count)
      assert_equal(group1, school.groups.first)

      organization1 = Organisation.find_by(name: '1 Organisation')
      assert_equal(3, organization1.groups.count)
    end

    def test_nested_has_many_creation
      group = Group.find_by(name: 'Test nested has_many creation')
      assert_not_nil(group)
      user = User.find_by(firstname: 'Created in nested group')
      assert_not_nil(user)
    end
  end

  class FixtureKitHabtmTest < BaseTest
    def setup
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
    end

    def test_habtm_relation
      geoffroy = User.find_by(firstname: 'Geoffroy')
      user1 = User.find_by(firstname: 'Margot')
      print = Group.find_by(name: 'Print')

      assert_equal(3, print.users.count)
      assert(print.users.include?(geoffroy))
      assert(print.users.include?(user1))
      assert_equal(print, user1.groups.first)
    end
  end

  class FixtureKitEmbeddedTest < BaseTest
    def setup
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
    end

    def test_embeds_one_relation
      user1 = User.find_by(firstname: 'Margot')
      assert_not_nil(user1.address)
      assert_equal('Strasbourg', user1.address.city)
    end

    def test_embeds_many_relation
      user1 = User.find_by(firstname: 'Margot')
      assert_equal(1, user1.homes.count)
      assert_equal('Home', user1.homes.first.name)
    end

    def test_embedded_belongs_to_resolved
      user1 = User.find_by(firstname: 'Margot')
      organization1 = Organisation.find_by(name: '1 Organisation')
      assert_equal(organization1, user1.address.organisation)
    end
  end

  class FixtureKitDocumentCountTest < BaseTest
    def setup
      util = Mongoid::FixtureKit::Util.new
      util.reset_cache
      @fs = util.create_fixtures('test/fixtures/', %w[users groups schools organisations])
    end

    def test_document_counts
      assert_equal(6, School.count)
      assert_equal(6, User.count)
    end

    def test_fixture_find_returns_correct_document
      users = @fs.find { |x| x.model_class == User }
      f_geoffroy = users['geoffroy']
      geoffroy = User.find_by(firstname: 'Geoffroy')
      assert_equal(geoffroy, f_geoffroy.find)
    end
  end
end
