# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Okr Service for PostgreSQL
    #
    # Provides CRUD operations for the 'okrs' table using the Base service.
    class Okr < Services::Postgres::Base
      ATTRIBUTES = %i[external_okr_id code status objective].freeze

      TABLE = :okrs
      HISTORY_TABLE = :okrs_history
      HISTORY_FOREIGN_KEY = :okr_id

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Okr id is required to update' unless id

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
        puts "[Okr Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
