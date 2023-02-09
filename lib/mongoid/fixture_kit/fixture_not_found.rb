require 'mongoid/fixture_kit/fixture_error'

module Mongoid
  class FixtureKit
    class FixtureNotFound < FixtureError
    end
  end
end
