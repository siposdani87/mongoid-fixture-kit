module Mongoid
  class FixtureKit
    class RenderContext
      def binder
        binding
      end
    end
  end
end
