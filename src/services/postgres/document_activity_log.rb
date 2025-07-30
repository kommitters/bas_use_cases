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
      ATTRIBUTES = %i[document_id person_id action details].freeze
      TABLE = :document_activity_logs

      RELATIONS = [
        { service: Document, external: :external_document_id, internal: :document_id },
        { service: Person, external: :external_person_id, internal: :person_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'DocumentActivityLog id is required to update' unless id

        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
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

      def handle_error(error)
        puts "[DocumentActivityLog Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
