# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'
require_relative 'kpi_history'

module Services
  module Postgres
    ##
    # Kpi Service for PostgreSQL
    #
    # Provides CRUD operations for the 'kpis' table using the Base service.
    class Kpi < Services::Postgres::Base
      ATTRIBUTES = %i[external_kpi_id domain_id description status current_value percentage target_value stats].freeze
      TABLE = :kpis

      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'KPI id is required to update' unless id

        assign_relations(params)
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

      def save_history(id)
        kpi = find(id).merge(kpi_id: id)
        kpi.delete(:id)

        KpiHistory.new(db).insert(kpi)
      end

      def handle_error(error)
        puts "[Kpi Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
