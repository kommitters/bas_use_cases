# frozen_string_literal: true

require_relative 'base'
require_relative 'activity'
require_relative 'project'
require_relative 'domain'
require_relative 'person'

module Services
  module Postgres
    ##
    # WorkItem Service for PostgreSQL
    #
    # Provides CRUD operations for the 'work_items' table using the Base service.
    class WorkItem < Services::Postgres::Base
      TABLE = :work_items

      RELATIONS = [
        { service: Project, external: :external_project_id, internal: :project_id },
        { service: Activity, external: :external_activity_id, internal: :activity_id },
        { service: Domain, external: :external_domain_id, internal: :domain_id },
        { service: Person, external: :external_person_id, internal: :person_id }
      ].freeze

      def insert(params)
        params = params.dup
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Work item id is required to update' unless id

        params = params.dup
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

      def handle_error(error)
        puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
