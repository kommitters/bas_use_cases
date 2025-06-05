# frozen_string_literal: true

require 'sequel'
require_relative 'base'

module Services
  ##
  # Project Service for PostgreSQL
  #
  # Provides CRUD operations for the 'project' table using the Base service.
  class Project < Services::Base
    TABLE = :project

    # Inserts a new project record.
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # Updates a project by ID
    def update(params)
      id = params.delete(:id) || params.delete('id')
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
    end

    # Queries projects by conditions.
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    # Handles and logs errors, then re-raises them.
    def handle_error(error)
      puts "[Project Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
