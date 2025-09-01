# frozen_string_literal: true

require_relative 'base'
require_relative 'document'
require_relative 'person'

module Services
  module Postgres
    ##
    # DocumentActivityLog Service for PostgreSQL
    #
    # Provides CRUD operations for the 'document_activity_logs' table using the Base service.
    class DocumentActivityLog < Services::Postgres::Base
      ATTRIBUTES = %i[document_id person_id action details unique_identifier].freeze

      TABLE = :document_activity_logs

      RELATIONS = [
        { service: Document, external: :external_document_id, internal: :document_id },
        { service: Person, external: :email_address, internal: :person_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, polished_attributes(params)) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'DocumentActivityLog id is required to update' unless id

        assign_relations(params)
        transaction { update_item(TABLE, id, polished_attributes(params)) }
      rescue StandardError => e
        handle_error(e)
      end

      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      def find(id)
        find_item(TABLE, id)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      def polished_attributes(params)
        attributes = params.slice(*ATTRIBUTES)
        return attributes unless attributes.key?(:details)

        attributes[:details] = if db.adapter_scheme == :postgres
                                 Sequel.pg_json(attributes[:details] || {})
                               else
                                 attributes[:details].to_json
                               end
        attributes
      end

      def handle_error(error)
        puts "[DocumentActivityLog Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
