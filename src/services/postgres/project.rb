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

    # @raise [StandardError] Re-raises any error encountered during insertion after logging
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # @raise [StandardError] If an error occurs during the update process
    def update(params)
      id = params.delete(:id) || params.delete('id')
      raise ArgumentError, 'Project id is required to update' unless id

      transaction { update_item(TABLE, id, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # @raise [StandardError] Re-raises any error encountered during deletion after logging.
    def delete(id)
      transaction { delete_item(TABLE, id) }
    rescue StandardError => e
      handle_error(e)
    end

    ##
    # Retrieves a project record by its unique identifier.
    #
    # @param id [Integer] The unique ID of the project to retrieve.
    # @return [Hash, nil] The project record if found, or nil if not found.
    def find(id)
      find_item(TABLE, id)
    end

    ##
    # Retrieves project records matching the specified conditions.
    #
    # @param conditions [Hash] Optional filters to apply to the project query.
    # @return [Array<Hash>] List of project records matching the conditions.
    #
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    # @raise [Exception] Always re-raises the provided error.
    def handle_error(error)
      puts "[Project Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
