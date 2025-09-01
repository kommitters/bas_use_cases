# frozen_string_literal: true

require_relative 'base'
require_relative 'person'
require_relative 'project'
require_relative 'activity'
require_relative 'work_item'

module Services
  module Postgres
    ##
    # WorkLog Service for PostgreSQL
    #
    # Provides CRUD operations for the 'work_logs' table using the Base service.
    class WorkLog < Services::Postgres::Base
      ATTRIBUTES = %i[
        external_work_log_id duration_minutes tags person_id
        project_id activity_id work_item_id creation_date modification_date
        external deleted started_at description
      ].freeze

      TABLE = :work_logs
      HISTORY_TABLE = :work_logs_history
      HISTORY_FOREIGN_KEY = :work_log_id

      RELATIONS = [
        { service: Person, external: :external_person_id, internal: :person_id },
        { service: Project, external: :external_project_id, internal: :project_id },
        { service: Activity, external: :external_activity_id, internal: :activity_id },
        { service: WorkItem, external: :external_work_item_id, internal: :work_item_id }
      ].freeze

      def insert(params)
        assign_relations(params)

        transaction do
          insert_item(TABLE, params)
        end
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'WorkLog id is required to update' unless id

        assign_relations(params)

        transaction do
          update_item(TABLE, id, params)
        end
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
        puts "[WorkLog Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
