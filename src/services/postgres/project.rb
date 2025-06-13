# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'

module Services
  module Postgres
    ##
    # Project Service for PostgreSQL
    #
    # Provides CRUD operations for the 'projects' table using the Base service.
    class Project < Services::Postgres::Base
      TABLE = :projects

      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id }
      ].freeze

      # Insert a new project record.
      def insert(params)
        params = params.dup
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      # Updates a project by ID
      def update(id, params)
        raise ArgumentError, 'Project id is required to update' unless id

        params = params.dup
        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
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

      # Assigns foreign keys based on external IDs in params.
      def assign_relations(params)
        RELATIONS.each do |relation|
          next unless params.key?(relation[:external])

          params[relation[:internal]] = fetch_foreign_id(params[relation[:external]], relation)
          params.delete(relation[:external])
        end
      end

      # Fetches the foreign ID from the related service based on the external ID.
      def fetch_foreign_id(external_id, relation)
        return nil unless external_id

        record = relation[:service].new(db).query(relation[:external] => external_id).first
        record ? record[:id] : nil
      end

      # Handles and logs errors, then re-raises them.
      def handle_error(error)
        puts "[Project Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
