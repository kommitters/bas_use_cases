# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'

module Services
  module Postgres
    ##
    # Person Service for PostgreSQL
    #
    # Provides CRUD operations for the 'persons' table using the Base service.
    class Person < Services::Postgres::Base
      TABLE = :persons

      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id }
      ].freeze

      # Insert a new person record.
      def insert(params)
        params = params.dup
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a person by ID.
      def update(id, params)
        raise ArgumentError, 'Person id is required to update' unless id

        params = params.dup
        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a person by ID.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a person by ID.
      def find(id)
        find_item(TABLE, id)
      rescue StandardError => e
        handle_error(e)
      end

      # Queries persons by conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Person Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
