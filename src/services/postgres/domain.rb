# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Domain Service for PostgreSQL
    #
    # Provides CRUD operations for the 'domains' table using the Base service.
    class Domain < Services::Postgres::Base
      ATTRIBUTES = %i[external_domain_id name archived].freeze
      TABLE = :domains

      # Insert a new domain record.
      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a domain by ID.
      def update(id, params)
        raise ArgumentError, 'Domain id is required to update' unless id

        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a domain by ID.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a domain by ID.
      def find(id)
        find_item(TABLE, id)
      rescue StandardError => e
        handle_error(e)
      end

      # Queries domains by conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Domain Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
