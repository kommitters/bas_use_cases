# frozen_string_literal: true

require 'sequel'
require_relative 'base'

module Services
  ##
  # Activity Service for PostgreSQL
  #
  # Provides CRUD operations for the 'activity' table using the Base service.
  class Activity < Services::Base
    TABLE = :activity

    # @raise [StandardError] If the insert operation fails
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    ##
    # Updates an existing activity record identified by its ID.
    #
    # The `params` hash must include the `:id` (or `'id'`) key specifying the activity to update, along with any fields to be changed.
    #
    # @param params [Hash] Hash containing the activity ID and fields to update.
    # @return [void]
    # @raise [ArgumentError] If the `:id` key is missing from `params`.
    # @raise [StandardError] If a database or transaction error occurs.
    def update(params)
      id = params.delete(:id) || params.delete('id')
      raise ArgumentError, 'Activity id is required to update' unless id

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
    # Retrieves a single activity record by its unique ID.
    #
    # @param id [Integer] The unique identifier of the activity to retrieve.
    # @return [Hash, nil] The activity record if found, or nil if no matching record exists.
    def find(id)
      find_item(TABLE, id)
    end

    ##
    # Retrieves activity records matching the specified conditions.
    #
    # @param conditions [Hash] Optional filters to apply to the query.
    # @return [Array<Hash>] List of activity records matching the conditions.
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    ##
    # Logs the error details and re-raises the exception.
    #
    # @param error [Exception] The exception to handle and re-raise.
    # @raise [Exception] Always re-raises the provided exception.
    def handle_error(error)
      puts "[Activity Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
