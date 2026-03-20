require 'test_helper'

module Mongoid
  class FileTest < BaseTest
    def test_should_parse_yaml_with_erb
      fixtures = []
      Mongoid::FixtureKit::File.open('test/fixtures/schools.yml') do |f|
        f.each { |name, row| fixtures << [name, row] }
      end

      assert_equal(6, fixtures.length)
      assert_equal('school', fixtures.first[0])
      assert_equal('School', fixtures.first[1]['name'])
      assert_equal('school0', fixtures[1][0])
      assert_equal('School 0', fixtures[1][1]['name'])
    end

    def test_should_parse_erb_expressions
      fixtures = []
      Mongoid::FixtureKit::File.open('test/fixtures/organisations.yml') do |f|
        f.each { |name, row| fixtures << [name, row] }
      end

      org = fixtures.find { |name, _| name == 'organization1' }
      assert_equal('1 Organisation', org[1]['name'])
    end

    def test_should_raise_format_error_for_invalid_yaml
      # Create a temp file with invalid YAML
      tmpfile = Tempfile.new(['invalid', '.yml'])
      tmpfile.write("  bad:\n\tyaml: mixed tabs and spaces")
      tmpfile.rewind

      assert_raises(Mongoid::FixtureKit::FormatError) do
        Mongoid::FixtureKit::File.open(tmpfile.path) do |f|
          f.each { |_name, _row| }
        end
      end
    ensure
      tmpfile&.close
      tmpfile&.unlink
    end

    def test_should_return_empty_for_empty_file
      tmpfile = Tempfile.new(['empty', '.yml'])
      tmpfile.write('')
      tmpfile.rewind

      fixtures = []
      Mongoid::FixtureKit::File.open(tmpfile.path) do |f|
        f.each { |name, row| fixtures << [name, row] }
      end

      assert_equal(0, fixtures.length)
    ensure
      tmpfile&.close
      tmpfile&.unlink
    end

    def test_should_raise_format_error_for_non_hash_fixture
      tmpfile = Tempfile.new(['array', '.yml'])
      tmpfile.write("- item1\n- item2\n")
      tmpfile.rewind

      assert_raises(Mongoid::FixtureKit::FormatError) do
        Mongoid::FixtureKit::File.open(tmpfile.path) do |f|
          f.each { |_name, _row| }
        end
      end
    ensure
      tmpfile&.close
      tmpfile&.unlink
    end
  end
end
