# frozen_string_literal: true

require_relative 'base'
require_relative 'okr'

module Services
  module Postgres
    ##
    # Kr Service for PostgreSQL
    #
    # Provides CRUD operations for the 'krs' table using the Base service.
    class Kr < Services::Postgres::Base
      ATTRIBUTES = %i[external_kr_id okr_id description status code].freeze

      TABLE = :krs
      HISTORY_TABLE = :krs_history
      HISTORY_FOREIGN_KEY = :kr_id

      RELATIONS = [
        { service: Okr, external: :external_okr_id, internal: :okr_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Kr id is required to update' unless id

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
        puts "[Kr Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
