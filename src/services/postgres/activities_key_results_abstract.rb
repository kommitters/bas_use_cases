# frozen_string_literal: true

require_relative 'base_abstract'
require_relative 'key_result'
require_relative '../../../log/BasLogger'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    # Provides CRUD operations for the 'activities_key_results' table using the BaseAbstract service.
    class ActivitiesKeyResults < Services::Postgres::BaseAbstract
      ATTRIBUTES = %i[activity_id key_result_id].freeze

      TABLE = :activities_key_results
      RELATIONS = [
        { service: KeyResult, external: :external_key_result_id, internal: :key_result_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e, context: { action: 'insert', params: params })
      end

      def update(id, params)
        raise ArgumentError, 'ActivitiesKeyResults id is required to update' unless id

        assign_relations(params)
        transaction { update_item(TABLE, id, params) }
      rescue StandardError => e
        handle_error(e, context: { action: 'update', id: id, params: params })
      end

      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e, context: { action: 'delete', id: id })
      end

      def find(id)
        find_item(TABLE, id)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      def handle_error(error, context: {})
        BAS_LOGGER.error({
          service: 'ActivitiesKeyResults_service',
          error: "#{error.class}: #{error.message}",
          context: context
        })
        raise error
      end
    end
  end
end