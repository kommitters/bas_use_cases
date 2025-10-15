# frozen_string_literal: true

require_relative 'base'
require_relative 'operaton_process'

module Services
  module Postgres
    ##
    # OperatonActivity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'operaton_activities' table using the Base service.
    class OperatonActivity < Services::Postgres::Base
      ATTRIBUTES = %i[
        external_activity_id external_process_id process_definition_key
        activity_id activity_name activity_type task_id assignee
        start_time end_time duration_in_millis
      ].freeze

      TABLE = :operaton_activities

      RELATIONS = [
        { service: OperatonProcess, external: :external_process_id, internal: :process_id, key: :external_process_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Activity id is required to update' unless id

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
      rescue StandardError => e
        handle_error(e)
      end

      private

      def handle_error(error)
        puts "[Operaton Activity Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
