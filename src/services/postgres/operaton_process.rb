# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Process Service for PostgreSQL
    #
    # Provides CRUD operations for the 'processes' table using the Base service.
    class OperatonProcess < Services::Postgres::Base
      ATTRIBUTES = %i[
        external_process_id business_key process_definition_key
        process_definition_name start_time end_time duration_in_millis
        process_definition_version state
      ].freeze

      TABLE = :operaton_processes
      HISTORY_TABLE = :processes_history
      HISTORY_FOREIGN_KEY = :process_id

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Process id is required to update' unless id

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
      rescue StandardError => e
        handle_error(e)
      end

      private

      def handle_error(error)
        puts "[Process Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end