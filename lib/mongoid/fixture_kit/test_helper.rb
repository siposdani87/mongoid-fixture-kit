require 'mongoid/fixture_kit/util'

module Mongoid
  class FixtureKit
    module TestHelper
      extend ActiveSupport::Concern

      def before_setup
        super
        setup_fixtures
      end

      def after_teardown
        super
        teardown_fixtures
      end

      included do
        # rubocop:disable ThreadSafety/ClassAndModuleAttributes
        class_attribute :fixture_path
        class_attribute :fixture_kit_names
        class_attribute :load_fixtures_once
        class_attribute :cached_fixtures
        class_attribute :util
        # rubocop:enable ThreadSafety/ClassAndModuleAttributes

        self.fixture_path = nil
        self.fixture_kit_names = [].freeze
        self.load_fixtures_once = false
        self.cached_fixtures = nil
        self.util = Mongoid::FixtureKit::Util.new
      end

      class_methods do
        def fixtures(*fixture_kit_names)
          if fixture_kit_names.first == :all
            fixture_kit_names = Dir["#{fixture_path}/{**,*}/*.{yml}"]
            fixture_kit_names.map! { |f| f[(fixture_path.to_s.length + 1)..-5] }
          else
            fixture_kit_names = fixture_kit_names.flatten.map(&:to_s)
          end
          self.fixture_kit_names |= fixture_kit_names
          setup_fixture_accessors(fixture_kit_names)
        end

        def setup_fixture_accessors(fixture_kit_names = nil)
          fixture_kit_names = Array(fixture_kit_names || self.fixture_kit_names)
          methods = Module.new do
            fixture_kit_names.each do |fs_name|
              fs_name = fs_name.to_s
              accessor_name = fs_name.tr('/', '_').to_sym
              define_method(accessor_name) do |*fixture_names|
                force_reload = false
                force_reload = fixture_names.pop if fixture_names.last == true || fixture_names.last == :reload
                @fixture_cache[fs_name] ||= {}
                instances = fixture_names.map do |f_name|
                  f_name = f_name.to_s
                  @fixture_cache[fs_name].delete(f_name) if force_reload
                  raise FixtureNotFound, "No fixture named '#{f_name}' found for fixture set '#{fs_name}'" unless @loaded_fixtures[fs_name] && @loaded_fixtures[fs_name][f_name]
                  @fixture_cache[fs_name][f_name] ||= @loaded_fixtures[fs_name][f_name].find
                end
                instances.length == 1 ? instances.first : instances
              end
            end
          end
          include methods
        end
      end

      def setup_fixtures
        @fixture_cache = {}

        if self.class.cached_fixtures && self.class.load_fixtures_once
          self.class.fixtures(self.class.fixture_kit_names)
          @loaded_fixtures = self.class.cached_fixtures
        else
          self.class.util.reset_cache
          self.loaded_fixtures = load_fixtures
          self.class.cached_fixtures = @loaded_fixtures
        end
      end

      def teardown_fixtures
        self.class.util.reset_cache
      end

      private

      def load_fixtures
        fixture_kit_names = self.class.fixture_kit_names
        if fixture_kit_names.empty?
          self.class.fixtures(:all)
          fixture_kit_names = self.class.fixture_kit_names
        end
        self.class.util.create_fixtures(self.class.fixture_path, fixture_kit_names)
      end

      def loaded_fixtures=(fixtures)
        @loaded_fixtures = fixtures.dup.index_by(&:name)
      end
    end
  end
end
