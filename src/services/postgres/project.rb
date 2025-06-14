# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Project Service for PostgreSQL
    #
    # Provides CRUD operations for the 'projects' table using the Base service.
    class Project < Services::Postgres::Base
      TABLE = :projects

      # Insert a new project record.
      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a project by ID
      def update(id, params)
        raise ArgumentError, 'Project id is required to update' unless id

        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a project by ID.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a project by ID.
      def find(id)
        find_item(TABLE, id)
      rescue StandardError => e
        handle_error(e)
      end

      # Queries projects by conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Project Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
