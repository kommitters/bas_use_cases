# frozen_string_literal: true

require_relative 'base'
require_relative 'calendar_event_attendee'

module Services
  module Postgres
    ##
    # CalendarEvent Service for PostgreSQL
    #
    # Provides CRUD operations for the 'calendar_events' table using the Base service.
    class CalendarEvent < Services::Postgres::Base
      ATTRIBUTES = %i[external_calendar_event_id summary duration_minutes start_time end_time creation_timestamp].freeze

      TABLE = :calendar_events
      HISTORY_TABLE = :calendar_events_history
      HISTORY_FOREIGN_KEY = :calendar_event_id

      def insert(params)
        transaction do
          attendees = params.delete(:attendees)

          calendar_event_id = insert_item(TABLE, params)

          add_attendees_relations(calendar_event_id, attendees) if attendees

          calendar_event_id
        end
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Calendar event id is required to update' unless id

        transaction do
          attendees = params.delete(:attendees)

          update_attendees_relations(id, attendees) if attendees

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

      def add_attendees_relations(calendar_event_id, attendees)
        attendee_service = CalendarEventAttendee.new(db)

        attendees.each do |attendee_data|
          attributes = { calendar_event_id: calendar_event_id }.merge(attendee_data)
          attendee_service.insert(attributes)
        end
      end

      def update_attendees_relations(id, attendees)
        attendee_service = CalendarEventAttendee.new(db)

        existing_attendees = attendee_service.query(calendar_event_id: id)
        existing_attendees.each { |attendee| attendee_service.delete(attendee[:id]) }

        add_attendees_relations(id, attendees)
      end
    end
  end
end
