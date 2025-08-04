# frozen_string_literal: true

require_relative 'base'
require_relative 'domain' # Added to manage the relationship

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

      # Inserts a new KPI record into the database.
      def insert(params)
        assign_relations(params) # Resolve foreign keys from external IDs
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates an existing KPI record.
      def update(id, params)
        raise ArgumentError, 'KPI id is required to update' unless id

        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a KPI record from the database.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a single KPI record by its ID.
      def find(id)
        find_item(TABLE, id)
      end

      # Queries for KPI records based on a set of conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      # Handles and logs errors that occur within the service.
      def handle_error(error)
        puts "[Kpi Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
