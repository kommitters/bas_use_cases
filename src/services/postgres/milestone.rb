# frozen_string_literal: true

require_relative 'base'
require_relative 'project'

module Services
  module Postgres
    ##
    # Milestone Service for PostgreSQL
    #
    # Provides CRUD operations for the 'milestones' table using the Base service.
    class Milestone < Services::Postgres::Base
      ATTRIBUTES = %i[external_milestone_id name status completion_date project_id].freeze
      TABLE = :milestones

      RELATIONS = [
        { service: Project, external: :external_project_id, internal: :project_id }
      ].freeze

      # Insert a new milestone record.
      def insert(params)
        params = symbolize_keys(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a milestone by ID
      def update(id, params)
        raise ArgumentError, 'Milestone id is required to update' unless id

        params = symbolize_keys(params)
        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a milestone by ID.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a milestone by ID.
      def find(id)
        find_item(TABLE, id)
      rescue StandardError => e
        handle_error(e)
      end

      # Queries milestones by conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Milestone Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
