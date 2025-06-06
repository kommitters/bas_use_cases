# frozen_string_literal: true

require 'sequel'
require_relative 'base'

module Services
  module Postgres
    ##
    # WorkItem Service for PostgreSQL
    #
    # Provides CRUD operations for the 'work_items' table using the Base service.
    class WorkItem < Services::Postgres::Base
      TABLE = :work_items

      # Mapping of external IDs to internal IDs for relations.
      RELATIONS = {
        external_activity_id: {
          table: :activities,
          id_field: :activity_id,
          external_field: :external_activity_id
        },
        external_project_id: {
          table: :projects,
          id_field: :project_id,
          external_field: :external_project_id
        }
        # Here you can add more relations as needed
      }.freeze

      def insert(params)
        params = params.dup
        resolve_foreign_keys(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Work item id is required to update' unless id

        params = params.dup
        resolve_foreign_keys(params)
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

      # Resolves foreign keys in the params hash by querying the related tables.
      def resolve_foreign_keys(params)
        RELATIONS.each do |external_key, relation|
          next unless params[external_key]

          record = query_item(
            relation[:table],
            relation[:external_field] => params[external_key]
          ).first

          raise_relation_not_found(relation[:table], external_key, params[external_key]) if record.nil?

          params[relation[:id_field]] = record[:id]
          params.delete(external_key)
        end
      end

      def raise_relation_not_found(table, external_key, value)
        raise "#{table} not found for #{external_key}: #{value}"
      end

      def handle_error(error)
        puts "[WorkItem Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
