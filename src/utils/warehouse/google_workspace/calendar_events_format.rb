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
          @event_id ||= extract_parameter_value(create_event&.dig('parameters'), 'event_id')
        end

        def start_time
          @start_time ||= find_time_param(%w[start_time start_date])
        end

        def end_time
          @end_time ||= find_time_param(%w[end_time end_date])
        end

        def summary
          @summary ||= latest_title_change || extract_parameter_value(create_event&.dig('parameters'), 'event_title')
        end

        def attendees
          @attendees ||= all_attendee_emails.map do |email|
            {
              email_address: email,
              response_status: attendee_status_map.fetch(email, 'needsAction')
            }
          end
        end

        def latest_title_change
          @latest_title_change ||= begin
            change_event = find_latest_title_change_event
            extract_parameter_value(change_event&.dig('parameters'), 'event_title')
          end
        end

        def find_latest_title_change_event
          latest_activity = @data
                            .select { |activity| event_name?(activity, 'change_event_title') }
                            .max_by { |activity| activity.dig('id', 'time') }

          return nil unless latest_activity

          (latest_activity['events'] || []).find { |event| event['name'] == 'change_event_title' }
        end

        def all_attendee_emails
          @all_attendee_emails ||= @data.flat_map { |activity| extract_guests_from(activity) }.uniq
        end

        def attendee_status_map
          @attendee_status_map ||= @data
                                   .flat_map { |activity| activity['events'] || [] }
                                   .select { |event| event['name'] == 'change_event_guest_response' }
                                   .map { |event| extract_email_and_status_from(event) }
                                   .compact
                                   .to_h
        end

        def create_event_parameters
          create_event&.dig('parameters') || []
        end

        def find_time_param(param_names)
          param = create_event_parameters.find { |p| param_names.include?(p['name']) }
          extract_time_from_param(param)
        end

        def event_name?(activity, event_name)
          (activity['events'] || []).any? { |event| event['name'] == event_name }
        end

        def extract_guests_from(activity)
          (activity['events'] || []).flat_map do |event|
            (event['parameters'] || []).select { |p| p['name'] == 'event_guest' }.map { |p| p['value'] }
          end
        end

        def extract_email_and_status_from(event)
          params = event['parameters']
          email = extract_parameter_value(params, 'event_guest')
          status = extract_parameter_value(params, 'event_response_status')
          return nil unless email && status

          [email, status]
        end
      end
    end
  end
end
