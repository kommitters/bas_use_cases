# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'
require_relative 'projects_key_results'

module Services
  module Postgres
    ##
    # Project Service for PostgreSQL
    #
    # Provides CRUD operations for the 'projects' table using the Base service.
    class Project < Services::Postgres::Base
      ATTRIBUTES = %i[external_project_id name status domain_id].freeze

      TABLE = :projects
      HISTORY_TABLE = :projects_history
      HISTORY_FOREIGN_KEY = :project_id

      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id }
      ].freeze

      # Insert a new project record.
      def insert(params)
        assign_relations(params)

        transaction do
          project_id = insert_item(TABLE, params)

          add_key_results_relations(project_id, params) if params[:external_key_results_ids]

          project_id
        end
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a project by ID
      def update(id, params)
        raise ArgumentError, 'Project id is required to update' unless id

        assign_relations(params)
        transaction do
          update_key_results_relations(id, params) if params[:external_key_results_ids]
          update_item(TABLE, id, params)
        end
      rescue StandardError => e
        handle_error(e)
      end

      # Deletes a project by ID.
      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      # Finds a project by ID.
      def find(id)
        find_item(TABLE, id)
      rescue StandardError => e
        handle_error(e)
      end

      # Queries projects by conditions.
      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Project Service ERROR] #{error.class}: #{error.message}"
        raise error
      end

      def add_key_results_relations(project_id, params)
        service = ProjectsKeyResults.new(db)

        params[:external_key_results_ids].each do |external_id|
          attributes = { project_id: project_id, external_key_result_id: external_id }

          service.insert(attributes)
        end

        params.delete(:external_key_results_ids)
      end

      def update_key_results_relations(id, params)
        service = ProjectsKeyResults.new(db)
        projects_key_results = service.query(project_id: id)

        projects_key_results.each { |project_key_result| service.delete(project_key_result[:id]) }

        add_key_results_relations(id, params)
      end
    end
  end
end
