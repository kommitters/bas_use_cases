# frozen_string_literal: true

require_relative 'base'
require_relative 'calendar_event'
require_relative 'person'

module Services
  module Postgres
    ##
    # CalendarEventAttendee Service for PostgreSQL
    #
    # Provides CRUD operations for the 'calendar_event_attendees' table.
    class CalendarEventAttendee < Services::Postgres::Base
      ATTRIBUTES = %i[calendar_event_id person_id email response_status].freeze

      TABLE = :calendar_event_attendees

      RELATIONS = [
        { service: CalendarEvent, external: :external_calendar_event_id, internal: :calendar_event_id }
      ].freeze

      def insert(params)
        assign_relations(params)
        assign_person_from_email(params)

        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'Calendar event attendee id is required to update' unless id

        assign_relations(params)
        assign_person_from_email(params)

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

      def assign_person_from_email(params)
        return unless params[:email]

        person_service = Services::Postgres::Person.new(db)
        person = person_service.query(email_address: params[:email]).first

        params[:person_id] = person[:id] if person
      end

      def handle_error(error)
        puts "[CalendarEventAttendee Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
