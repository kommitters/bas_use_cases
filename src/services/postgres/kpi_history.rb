# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # KpiHistory Service for PostgreSQL
    #
    # Provides basic CRUD operations for the 'kpis_history' table.
    class KpiHistory < Services::Postgres::Base
      ATTRIBUTES = %i[ kpi_id external_kpi_id domain_id description status current_value percentage target_value
                       stats].freeze
      TABLE = :kpis_history

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'KpiHistory id is required to update' unless id

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
        puts "[KpiHistory Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
