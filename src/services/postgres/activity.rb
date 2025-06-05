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

    # Inserts a new activity record.
    def insert(params)
      transaction { insert_item(TABLE, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # Updates an activity by ID; params must include :id and fields to update.
    def update(params)
      id = params.delete(:id) || params.delete('id')
      raise ArgumentError, 'Activity id is required to update' unless id

      transaction { update_item(TABLE, id, params) }
    rescue StandardError => e
      handle_error(e)
    end

    # Deletes an activity by ID.
    def delete(id)
      transaction { delete_item(TABLE, id) }
    rescue StandardError => e
      handle_error(e)
    end

    # Finds an activity by ID.
    def find(id)
      find_item(TABLE, id)
    end

    # Queries activities by conditions.
    def query(conditions = {})
      query_item(TABLE, conditions)
    end

    private

    # Handles and logs errors, then re-raises them.
    def handle_error(error)
      puts "[Activity Service ERROR] #{error.class}: #{error.message}"
      raise error
    end
  end
end
