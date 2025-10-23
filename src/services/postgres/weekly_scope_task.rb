# frozen_string_literal: true

require_relative 'base'
require_relative 'task'
require_relative 'weekly_scope'

module Services
  module Postgres
    ##
    # WeeklyScopeTask Service for PostgreSQL
    #
    # Provides CRUD operations for the 'weekly_scope_tasks' table using the Base service.
    class WeeklyScopeTask < Services::Postgres::Base
      ATTRIBUTES = %i[external_weekly_scope_task_id task_id weekly_scope_id].freeze

      TABLE = :weekly_scope_tasks
      HISTORY_TABLE = :weekly_scope_tasks_history
      HISTORY_FOREIGN_KEY = :weekly_scope_task_id

      RELATIONS = [
        { service: Task, external: :external_task_id, internal: :task_id },
        { service: WeeklyScope, external: :external_weekly_scope_id, internal: :weekly_scope_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'WeeklyScopeTask id is required to update' unless id

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
        puts "[WeeklyScopeTask Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
