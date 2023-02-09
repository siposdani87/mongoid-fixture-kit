require 'mongoid/fixture_kit/fixture_error'

module Mongoid
  class FixtureKit
    class FixtureClassNotFound < FixtureError
    end
  end
end
