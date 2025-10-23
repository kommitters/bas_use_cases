# frozen_string_literal: true

require_relative 'base'
require_relative 'apex_process'
require_relative 'apex_milestone'

module Services
  module Postgres
    ##
    # Task Service for PostgreSQL
    #
    # Provides CRUD operations for the 'tasks' table using the Base service.
    class Task < Services::Postgres::Base
      ATTRIBUTES = %i[external_task_id process_id milestone_id name description assigned_to status start_date end_date
                      deadline].freeze

      TABLE = :tasks
      HISTORY_TABLE = :tasks_history
      HISTORY_FOREIGN_KEY = :task_id

      RELATIONS = [
        { service: ApexProcess, external: :external_process_id, internal: :process_id },
        { service: ApexMilestone, external: :external_apex_milestone_id, internal: :milestone_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Task id is required to update' unless id

        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      def find(id)
        find_item(TABLE, id)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      def handle_error(error)
        puts "[Task Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
