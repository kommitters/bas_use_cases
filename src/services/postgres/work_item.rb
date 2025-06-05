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

    # @raise [StandardError] If the insertion fails, the error is logged and re-raised.
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # @return [Integer] The number of records updated.
    def update(params)
      id = params.delete(:id) || params.delete('id')
      raise ArgumentError, 'Work item id is required to update' unless id

      transaction { update_item(TABLE, id, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # @raise [StandardError] If an error occurs during deletion, it is logged and re-raised.
    def delete(id)
      transaction { delete_item(TABLE, id) }
    rescue StandardError => e
      handle_error(e)
    end

    ##
    # Retrieves a work item record by its unique ID.
    #
    # @param id [Integer] The unique identifier of the work item.
    # @return [Hash, nil] The work item record if found, or nil if not found.
    def find(id)
      find_item(TABLE, id)
    end

    # @return [Array<Hash>] An array of work item records matching the conditions.
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    ##
    # Logs the error details and re-raises the exception.
    #
    # @param error [Exception] The error to handle and propagate.
    # @raise [Exception] Always re-raises the provided error.
    def handle_error(error)
      puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
