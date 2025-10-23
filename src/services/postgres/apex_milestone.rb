# frozen_string_literal: true

require_relative 'base'
require_relative 'kr'

module Services
  module Postgres
    ##
    # ApexMilestone Service for PostgreSQL
    #
    # Provides CRUD operations for the 'apex_milestones' table using the Base service.
    class ApexMilestone < Services::Postgres::Base
      ATTRIBUTES = %i[external_apex_milestone_id kr_id description milestone_order percentage completion_date
                      is_completed].freeze

      TABLE = :apex_milestones
      HISTORY_TABLE = :apex_milestones_history
      HISTORY_FOREIGN_KEY = :apex_milestone_id

      RELATIONS = [
        { service: Kr, external: :external_kr_id, internal: :kr_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'ApexMilestone id is required to update' unless id

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
        puts "[ApexMilestone Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
