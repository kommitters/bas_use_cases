# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # CalendarEvent Service for PostgreSQL
    #
    # Provides CRUD operations for the 'calendar_events' table using the Base service.
    class CalendarEvent < Services::Postgres::Base
      ATTRIBUTES = %i[external_calendar_event_id summary duration_minutes start_time end_time
                      creation_timestamp].freeze

      TABLE = :calendar_events

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Calendar event id is required to update' unless id

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

      def handle_error(error)
        puts "[CalendarEvent Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
