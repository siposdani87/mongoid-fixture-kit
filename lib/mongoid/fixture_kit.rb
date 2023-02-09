require 'mongoid/fixture_kit/class_cache'
require 'mongoid/fixture_kit/file'
require 'mongoid/fixture_kit/fixture_class_not_found'
require 'mongoid/fixture_kit/fixture_not_found'
require 'mongoid/fixture_kit/fixture'
require 'mongoid/fixture_kit/format_error'
require 'mongoid/fixture_kit/test_helper'

module Mongoid
  class FixtureKit
    attr_reader :name
    attr_reader :path
    attr_reader :model_class
    attr_reader :class_name
    attr_reader :fixtures

    def initialize(name, class_name, path)
      @name = name
      @path = path

      if class_name.is_a?(Class)
        @model_class = class_name
      elsif class_name
        @model_class = class_name.safe_constantize
      end

      @class_name = if @model_class.respond_to?(:name)
                      @model_class.name
                    else
                      name.singularize.camelize
                    end

      @fixtures = read_fixture_files
    end

    delegate :[], to: :fixtures

    private

    def read_fixture_files
      files = Dir["#{path}/{**,*}/*.yml"].select do |f|
        ::File.file?(f)
      end
      yaml_files = files.push("#{path}.yml")

      yaml_files.each_with_object({}) do |file, fixtures|
        Mongoid::FixtureKit::File.open(file) do |f|
          f.each do |fixture_name, row|
            fixtures[fixture_name] = Mongoid::FixtureKit::Fixture.new(fixture_name, row, model_class)
          end
        end
      end
    end
  end
end
