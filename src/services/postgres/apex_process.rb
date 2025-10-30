# frozen_string_literal: true

require_relative 'base'
require_relative 'organizational_unit'

module Services
  module Postgres
    ##
    # ApexProcess Service for PostgreSQL
    #
    # Provides CRUD operations for the 'processes' table using the Base service.
    class ApexProcess < Services::Postgres::Base
      ATTRIBUTES = %i[external_process_id org_unit_id name description start_date end_date deadline status
                      external_id].freeze

      TABLE = :processes
      HISTORY_TABLE = :processes_history
      HISTORY_FOREIGN_KEY = :process_id

      RELATIONS = [
        { service: OrganizationalUnit, external: :external_org_unit_id, internal: :org_unit_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Process id is required to update' unless id

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
        puts "[ApexProcess Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
