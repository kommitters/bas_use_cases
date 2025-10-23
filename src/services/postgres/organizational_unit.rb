# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # OrganizationalUnit Service for PostgreSQL
    #
    # Provides CRUD operations for the 'organizational_units' table using the Base service.
    class OrganizationalUnit < Services::Postgres::Base
      ATTRIBUTES = %i[external_org_unit_id name status].freeze

      TABLE = :organizational_units
      HISTORY_TABLE = :organizational_units_history
      HISTORY_FOREIGN_KEY = :organizational_unit_id

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'OrganizationalUnit id is required to update' unless id

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
        puts "[OrganizationalUnit Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
