# frozen_string_literal: true

require_relative 'base'
require_relative 'activity'
require_relative 'project'
require_relative 'domain'
require_relative 'person'
require_relative 'weekly_scope'

module Services
  module Postgres
    ##
    # WorkItem Service for PostgreSQL
    #
    # Provides CRUD operations for the 'work_items' table using the Base service.
    class WorkItem < Services::Postgres::Base
      ATTRIBUTES = %i[name external_work_item_id project_id activity_id status completion_date weekly_scope_id
                      description domain_id person_id].freeze
      TABLE = :work_items

      RELATIONS = [
        { service: Project, external: :external_project_id, internal: :project_id },
        { service: Activity, external: :external_activity_id, internal: :activity_id },
        { service: Domain, external: :external_domain_id, internal: :domain_id },
        { service: Person, external: :external_person_id, internal: :person_id },
        { service: WeeklyScope, external: :external_weekly_scope_id, internal: :weekly_scope_id }
      ].freeze

      def insert(params)
        params = symbolize_keys(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Work item id is required to update' unless id

        params = symbolize_keys(params)
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
      rescue StandardError => e
        handle_error(e)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      def handle_error(error)
        puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
