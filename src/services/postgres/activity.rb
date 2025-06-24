# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'
require_relative 'activities_key_results'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'activities' table using the Base service.
    class Activity < Services::Postgres::Base
      ATTRIBUTES = %i[external_activity_id name domain_id].freeze
      TABLE = :activities
      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction do
          activity_id = insert_item(TABLE, params)

          add_key_results_relations(activity_id, params) if params[:external_key_results_ids]

          activity_id
        end
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Activity id is required to update' unless id

        assign_relations(params)
        transaction do
          update_key_results_relations(id, params) if params[:external_key_results_ids]
          update_item(TABLE, id, params)
        end
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
        puts "[Activity Service ERROR] #{error.class}: #{error.message}"
        raise error
      end

      def add_key_results_relations(activity_id, params)
        service = ActivitiesKeyResults.new(db)

        params[:external_key_results_ids].each do |external_id|
          attributes = { activity_id: activity_id, external_key_result_id: external_id }

          service.insert(attributes)
        end

        params.delete(:external_key_results_ids)
      end

      def update_key_results_relations(id, params)
        service = ActivitiesKeyResults.new(db)
        activities_key_results = service.query(activity_id: id)

        activities_key_results.each { |activity_key_result| service.delete(activity_key_result[:id]) }

        add_key_results_relations(id, params)
      end
    end
  end
end
