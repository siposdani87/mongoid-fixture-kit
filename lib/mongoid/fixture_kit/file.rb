require 'mongoid/fixture_kit/render_context'

module Mongoid
  class FixtureKit
    class File
      include Enumerable

      def self.open(file)
        x = new file
        block_given? ? yield(x) : x
      end

      def initialize(file)
        @file = file
        @rows = nil
      end

      def each(&)
        rows.each(&)
      end

      private

      def rows
        return @rows if @rows
        begin
          data = YAML.safe_load(render(::File.read(@file)))
        rescue ArgumentError, Psych::SyntaxError => e
          raise FormatError, "a YAML error occurred parsing #{@file}. Please note that YAML must be consistently indented using spaces. Tabs are not allowed. Please have a look at http://www.yaml.org/faq.html\nThe exact error was:\n #{e.class}: #{e}", e.backtrace
        end
        @rows = data ? validate(data).to_a : []
      end

      def render(content)
        context = Mongoid::FixtureKit::RenderContext.create_subclass.new
        ERB.new(content).result(context.binder)
      end

      def validate(data)
        raise FormatError, 'fixture is not a hash' unless data.is_a?(Hash) || data.is_a?(YAML::Omap)
        raise FormatError unless data.all? { |_name, row| row.is_a?(Hash) }
        data
      end
    end
  end
end
