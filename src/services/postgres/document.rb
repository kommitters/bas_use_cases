# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'documents' table using the Base service.
    class Document < Services::Postgres::Base
      TABLE = :documents

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Document id is required to update' unless id

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
        puts "[Document Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
