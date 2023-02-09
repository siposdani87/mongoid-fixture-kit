require 'mongoid/fixture_kit'

module Mongoid
  module Document
    attr_accessor :__fixture_name
  end
end
