# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'key_results_history' table using the Base service.
    class KeyResultsHistory < Services::Postgres::Base
      ATTRIBUTES = %i[key_result_id external_key_result_id okr key_result metric current progress period
                      objective].freeze
      TABLE = :key_results_history

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'KeyResultsHistory id is required to update' unless id

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
        puts "[KeyResultsHistory Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
