# frozen_string_literal: true

require_relative 'base'
require_relative 'key_results_history'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'key_results' table using the Base service.
    class KeyResults < Services::Postgres::Base
      ATTRIBUTES = %i[external_key_result_id okr key_result metric current progress period objective].freeze
      TABLE = :key_results

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'KeyResults id is required to update' unless id

        transaction do
          save_history(id)

          update_item(TABLE, id, params)
        end
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
        puts "[KeyResults Service ERROR] #{error.class}: #{error.message}"
        raise error
      end

      def save_history(id)
        key_result = find(id).merge(key_result_id: id)
        key_result.delete(:id)

        KeyResultsHistory.new(db).insert(key_result)
      end
    end
  end
end
