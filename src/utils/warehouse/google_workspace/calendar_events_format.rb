# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module GoogleWorkspace
      ##
      # Class for formatting Google Calendar events from activity data.
      # It extracts relevant information such as event ID, start time, end time,
      # summary, duration, and attendees from the activity data.
      class CalendarEventsFormatter < Base
        # Main method that returns a hash with formatted event data.
        def format
          return nil unless create_event && event_id

          {
            external_calendar_event_id: event_id,
            summary: summary,
            start_time: start_time,
            end_time: end_time,
            duration_minutes: calculate_duration(start_time, end_time),
            creation_timestamp: extract_creation_timestamp,
            attendees: attendees
          }
        end

        private

        def create_event
          @create_event ||= extract_event_by_name('create_event')
        end

        def event_id
          @event_id ||= extract_parameter_value(create_event&.parameters, 'event_id')
        end

        def start_time
          @start_time ||= extract_time_from_param(
            create_event.parameters.find { |p| %w[start_time start_date].include?(p.name) }
          )
        end

        def end_time
          @end_time ||= extract_time_from_param(
            create_event.parameters.find { |p| %w[end_time end_date].include?(p.name) }
          )
        end

        def summary
          @summary ||= latest_title_change || extract_parameter_value(create_event.parameters, 'event_title')
        end

        def attendees
          @attendees ||= all_attendee_emails.map do |email|
            {
              email: email,
              response_status: attendee_status_map.fetch(email, 'needsAction')
            }
          end
        end

        def latest_title_change
          @latest_title_change ||= begin
            change_event = find_latest_title_change_event
            extract_parameter_value(change_event&.parameters, 'event_title')
          end
        end

        def find_latest_title_change_event
          title_change_activities = @data.select do |activity|
            activity.events&.any? { |event| event.name == 'change_event_title' }
          end

          return nil if title_change_activities.empty?

          latest_activity = title_change_activities.max_by { |activity| activity.id.time }
          latest_activity.events.find { |event| event.name == 'change_event_title' }
        end

        def all_attendee_emails
          @all_attendee_emails ||= @data.flat_map do |activity|
            activity.events.flat_map do |event|
              event.parameters.select { |p| p.name == 'event_guest' }.map(&:value)
            end
          end.uniq
        end

        def attendee_status_map
          @attendee_status_map ||= @data.each_with_object({}) do |activity, map|
            activity.events.select { |e| e.name == 'change_event_guest_response' }.each do |event|
              params = event.parameters
              email = extract_parameter_value(params, 'event_guest')
              status = extract_parameter_value(params, 'event_response_status')
              map[email] = status if email && status
            end
          end
        end
      end
    end
  end
end
