# frozen_string_literal: true

require_relative 'base'
require_relative 'key_results'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'projects_key_results' table using the Base service.
    class ProjectsKeyResults < Services::Postgres::Base
      ATTRIBUTES = %i[project_id key_result_id].freeze
      TABLE = :projects_key_results
      RELATIONS = [
        { service: KeyResults, external: :external_key_result_id, internal: :key_result_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'ProjectsKeyResults id is required to update' unless id

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
        puts "[ProjectsKeyResults Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
