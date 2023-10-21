module Mongoid
  class FixtureKit
    class RenderContext
      def self.create_subclass
        Class.new Mongoid::FixtureKit.context_class do
          def binder
            binding
          end
        end
      end
    end
  end
end
