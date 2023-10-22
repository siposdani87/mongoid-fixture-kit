module Mongoid
  class FixtureKit
    class Util
      def initialize
        @cached_fixtures = {}
        @all_loaded_fixtures = {}
      end

      def cached_fixtures(keys_to_fetch = nil)
        if keys_to_fetch
          @cached_fixtures.values_at(*keys_to_fetch)
        else
          @cached_fixtures.values
        end
      end

      def reset_cache
        @cached_fixtures.clear
      end

      def fixture_is_cached?(name)
        @cached_fixtures[name]
      end

      def cache_fixtures(fixtures_map)
        @cached_fixtures.update(fixtures_map)
      end

      def update_all_loaded_fixtures(fixtures_map)
        @all_loaded_fixtures = fixtures_map
      end

      def create_fixtures(fixtures_directory, fixture_kit_names, class_names = {})
        fixture_kit_names = Array(fixture_kit_names).map(&:to_s)
        class_names = Mongoid::FixtureKit::ClassCache.new(class_names)

        files_to_read = fixture_kit_names.reject do |fs_name|
          fixture_is_cached?(fs_name)
        end

        return cached_fixtures(fixture_kit_names) if files_to_read.empty?

        fixtures_map = {}
        fixture_kits = files_to_read.map do |fs_name|
          fixtures_map[fs_name] = Mongoid::FixtureKit.new(fs_name, class_names[fs_name], ::File.join(fixtures_directory, fs_name))
        end

        update_all_loaded_fixtures(fixtures_map)

        fixture_kits.each do |fixture_kit|
          collection_documents(fixture_kit).each do |model, documents|
            model = class_names[model]
            next unless model
            documents.each do |attributes|
              create_or_update_document(model, attributes)
            end
          end
        end

        cache_fixtures(fixtures_map)
        cached_fixtures(fixture_kit_names)
      end

      def create_or_update_document(model, attributes)
        model = model.constantize if model.is_a? String

        document = find_or_create_document(model, attributes['__fixture_name'])
        update_document(document, attributes)
      end

      def update_document(document, attributes)
        attributes.delete('_id') if document.attributes.key?('_id')

        keys = (attributes.keys + document.attributes.keys).uniq
        keys.each do |key|
          value = attributes[key] || document[key]
          if key.include?('_translations')
            document.public_send("#{key}=", value)
          elsif attributes[key].instance_of?(Array) || document[key].instance_of?(Array)
            document[key] = Array(attributes[key]) + Array(document[key])
          else
            document[key] = value
          end
        end

        sanitize_new_embedded_documents(document)
        save_document(document)
        document
      end

      def sanitize_new_embedded_documents(document, is_new: false)
        document.relations.each do |name, relation|
          case macro_from_relation(relation)
          when :embeds_one
            if (document.changes[name] && !document.changes[name][1].nil?) ||
              (is_new && document[name])
              embedded_document = document.public_send(relation.name)
              embedded_document_set_default_values(embedded_document, document[name])
            end
          when :embeds_many
            if (document.changes[name] && !document.changes[name][1].nil?) ||
              (is_new && document[name])
              embedded_documents = document.public_send(relation.name)
              embedded_documents.each_with_index do |embedded_document, i|
                embedded_document_set_default_values(embedded_document, document[name][i])
              end
            end
          when :belongs_to
            if is_new && document.attributes[name]
              value = document.attributes.delete(name)
              raise Mongoid::FixtureKit::FixtureError, 'Unable to create nested document inside an embedded document' if value.is_a?(Hash)
              doc = find_or_create_document(relation.class_name, value)
              document.attributes[relation.foreign_key] = doc.id
            end
          else
            # type code here
          end
        end
      end

      def embedded_document_set_default_values(document, attributes)
        sanitize_new_embedded_documents(document, is_new: true)
        attributes.delete('_id')
        removable_fields =
          document.fields.select do |k, v|
            k != '_id' && v.default_val.present? && attributes[k] == document[k]
          end
        removable_fields.each do |k, _v|
          attributes.delete(k)
        end
      end

      def find_or_create_document(model, fixture_name)
        model = model.constantize if model.is_a? String

        document = model.where('__fixture_name' => fixture_name).first
        if document.nil?
          document = model.new
          document['__fixture_name'] = fixture_name
          begin
            save_document(document)
          rescue StandardError => e
            Rails.logger.debug document.attributes
            Rails.logger.debug e
            Rails.logger.debug { "Backtrace:\n\t#{e.backtrace.join("\n\t")}" }
          end
        end
        document
      end

      def macro_from_relation(relation)
        return relation.macro if defined?(Mongoid::Relations) && relation.instance_of?(Mongoid::Relations::Metadata)
        relation.class.name.split('::').last.underscore.to_sym
      end

      def collection_documents(fixture_kit)
        # allow a standard key to be used for doing defaults in YAML
        fixture_kit.fixtures.delete('DEFAULTS')

        # track any join collection we need to insert later
        documents = {}
        documents[fixture_kit.class_name] = fixture_kit.fixtures.map do |label, fixture|
          unmarshall_fixture(label, fixture, fixture_kit.model_class)
        end
        documents
      end

      private

      def save_document(doc)
        doc.save({ validate: false })
      end

      def unmarshall_fixture(label, attributes, model_class)
        model_class = model_class.constantize if model_class.is_a? String
        attributes = attributes.to_hash

        if label
          attributes['__fixture_name'] = label

          # interpolate the fixture label
          attributes.each do |key, value|
            attributes[key] = value.gsub('$LABEL', label) if value.is_a?(String)
          end
        end

        return attributes if model_class.nil?

        unless attributes.key?('_id')
          document = if label
                       find_or_create_document(model_class, label)
                     else
                       model_class.new
                     end
          attributes['_id'] = document.id
        end

        set_attributes_timestamps(model_class, attributes)

        model_class.relations.each_value do |relation|
          case macro_from_relation(relation)
          when :belongs_to
            unmarshall_belongs_to(model_class, attributes, relation)
          when :has_many
            unmarshall_has_many(model_class, attributes, relation)
          when :has_and_belongs_to_many
            unmarshall_has_and_belongs_to_many(model_class, attributes, relation)
          else
            # type code here
          end
        end

        attributes
      end

      def unmarshall_belongs_to(_model_class, attributes, relation)
        value = attributes.delete(relation.name.to_s)
        return if value.nil?

        if value.is_a? Hash
          raise Mongoid::FixtureKit::FixtureError, 'Unable to create document from nested attributes in a polymorphic relation' if relation.polymorphic?
          document = relation.class_name.constantize.new
          value = unmarshall_fixture(nil, value, relation.class_name)
          document = update_document(document, value)
          attributes[relation.foreign_key] = document.id
          return
        end

        if relation.polymorphic? && value.sub!(/\s*\(([^)]*)\)\s*/, '')
          type = Regexp.last_match(1)
          attributes[relation.inverse_type] = type
          attributes[relation.foreign_key] = find_or_create_document(type, value).id
        else
          attributes[relation.foreign_key] = find_or_create_document(relation.class_name, value).id
        end
      end

      def unmarshall_has_many(model_class, attributes, relation)
        values = attributes.delete(relation.name.to_s)
        return if values.nil?

        values.each do |value|
          if value.is_a? Hash
            document = relation.class_name.constantize.new
            value[relation.foreign_key] = attributes['_id']
            value[relation.type] = model_class.name if relation.polymorphic?
            value = unmarshall_fixture(nil, value, relation.class_name)
            update_document(document, value)
            next
          end

          document = find_or_create_document(relation.class_name, value)
          if relation.polymorphic?
            update_document(document, { relation.foreign_key => attributes['_id'], relation.type => model_class.name })
          else
            update_document(document, { relation.foreign_key => attributes['_id'] })
          end
        end
      end

      def unmarshall_has_and_belongs_to_many(_model_class, attributes, relation)
        values = attributes.delete(relation.name.to_s)
        return if values.nil?

        key = relation.foreign_key
        attributes[key] = []

        values.each do |value|
          if value.is_a? Hash
            document = relation.class_name.constantize.new
            value[relation.inverse_foreign_key] = Array(attributes['_id'])
            value = unmarshall_fixture(nil, value, relation.class_name)
            update_document(document, value)
            attributes[key] << document.id
            next
          end

          document = find_or_create_document(relation.class_name, value)
          attributes[key] << document.id

          update_document(document, { relation.inverse_foreign_key => Array(attributes['_id']) })
        end
      end

      def set_attributes_timestamps(model_class, attributes)
        now = Time.now.utc

        attributes['c_at'] = now if model_class < Mongoid::Timestamps::Created::Short && !attributes.key?('c_at')
        attributes['created_at'] = now if model_class < Mongoid::Timestamps::Created && !attributes.key?('created_at')

        attributes['u_at'] = now if model_class < Mongoid::Timestamps::Updated::Short && !attributes.key?('u_at')
        attributes['updated_at'] = now if model_class < Mongoid::Timestamps::Updated && !attributes.key?('updated_at')
      end
    end
  end
end
