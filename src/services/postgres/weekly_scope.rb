# frozen_string_literal: true

require_relative 'base'
require_relative 'domain'
require_relative 'person'

module Services
  module Postgres
    ##
    # Activity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'weekly_scope' table using the Base service.
    class WeeklyScope < Services::Postgres::Base
      ATTRIBUTES = %i[external_weekly_scope_id description start_week_date end_week_date domain_id person_id].freeze
      TABLE = :weekly_scopes
      RELATIONS = [
        { service: Domain, external: :external_domain_id, internal: :domain_id },
        { service: Person, external: :external_person_id, internal: :person_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'WeeklyScope id is required to update' unless id

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
        puts "[WeeklyScope Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
