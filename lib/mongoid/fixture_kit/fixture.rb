module Mongoid
  class FixtureKit
    class Fixture
      include Enumerable

      attr_reader :name
      attr_reader :fixture
      attr_reader :model_class

      def initialize(name, fixture, model_class)
        @name = name
        @fixture = fixture
        @model_class = model_class
      end

      def class_name
        model_class&.name
      end

      def each(&)
        fixture.each(&)
      end

      delegate :[], to: :fixture

      alias to_hash fixture

      def find
        raise FixtureClassNotFound, 'No class attached to find.' unless model_class
        model_class.unscoped do
          model_class.find_by('__fixture_name' => name)
        end
      end
    end
  end
end
