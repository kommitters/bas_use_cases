# frozen_string_literal: true

require_relative 'base'
require_relative 'activity'
require_relative 'project'

module Services
  module Postgres
    ##
    # WorkItem Service for PostgreSQL
    #
    # Provides CRUD operations for the 'work_items' table using the Base service.
    class WorkItem < Services::Postgres::Base
      TABLE = :work_items

      def insert(params)
        params = params.dup
        assign_activity_id(params)
        assign_project_id(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Work item id is required to update' unless id

        params = params.dup
        assign_activity_id(params)
        assign_project_id(params)
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
      rescue StandardError => e
        handle_error(e)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      def project_id(id)
        return nil unless id

        Project.new(db).query(external_project_id: id).first
      end

      def activity_id(id)
        return nil unless id

        Activity.new(db).query(external_activity_id: id).first
      end

      def assign_activity_id(params)
        return unless params.key?(:external_activity_id)

        if params[:external_activity_id]
          activity = activity_id(params[:external_activity_id])
          params[:activity_id] = activity[:id] if activity
        end
        params.delete(:external_activity_id)
      end

      def assign_project_id(params)
        return unless params.key?(:external_project_id)

        if params[:external_project_id]
          project = project_id(params[:external_project_id])
          params[:project_id] = project[:id] if project
        end
        params.delete(:external_project_id)
      end

      def handle_error(error)
        puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
