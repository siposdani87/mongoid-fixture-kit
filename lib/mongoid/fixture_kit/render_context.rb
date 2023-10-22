module Mongoid
  class FixtureKit
    module RenderContext
      module_function

      def create_subclass
        Class.new(Mongoid::FixtureKit.context_class) do
          def binder
            binding
          end
        end
      end
    end
  end
end
