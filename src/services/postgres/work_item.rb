# frozen_string_literal: true

require 'sequel'
require_relative 'base'

module Services
  ##
  # WorkItem Service for PostgreSQL
  #
  # Provides CRUD operations for the 'work_item' table using the Base service.
  class WorkItem < Services::Base
    TABLE = :work_item

    # Inserts a new work item record.
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # Updates a work item by ID; params must include :id and fields to update.
    def update(params)
      id = params.delete(:id) || params.delete('id')
      raise ArgumentError, 'Work item id is required to update' unless id

      transaction { update_item(TABLE, id, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # Deletes a work item by ID.
    def delete(id)
      transaction { delete_item(TABLE, id) }
    rescue StandardError => e
      handle_error(e)
    end

    # Finds a work item by ID.
    def find(id)
      find_item(TABLE, id)
    end

    # Queries work items by conditions.
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    # Handles and logs errors, then re-raises them.
    def handle_error(error)
      puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
