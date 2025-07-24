# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../services/google_workspace/reports'
require_relative '../utils/warehouse/google_workspace/calendar_events_format'

module Implementation
  ##
  # FetchWorkspaceCalendarEvents bot implementation.
  # This bot fetches calendar events for all users in the Google Workspace domain.
  # It uses the Google Calendar API to retrieve events and formats them for storage.
  #
  class FetchWorkspaceCalendarEvents < Bas::Bot::Base
    DEFAULT_START_DATE = Time.new(2025, 5, 1).freeze

    def process
      reports_service = Services::GoogleWorkspace::Reports.new(google_config)

      activities_response = reports_service.fetch_calendar_activities(start_time: filters[:since])
      return error_response(activities_response[:error][:message]) if activities_response[:error]

      all_activities = activities_response[:success][:activities]

      formatted_events = normalize_response(all_activities)
      { success: { type: 'calendar_event', content: formatted_events } }
    end

    private

    def filters
      { since: fetch_last_run_timestamp || DEFAULT_START_DATE }
    end

    def fetch_last_run_timestamp
      last_run = read_response&.inserted_at
      return unless last_run

      Time.parse(last_run.to_s)
    end

    def google_config
      {
        keyfile_path: process_options[:google_keyfile_path],
        admin_email: process_options[:google_admin_email]
      }
    end

    def normalize_response(activities)
      activities_by_event_id = (activities || []).group_by do |activity|
        event = activity.events.first
        param = event.parameters.find { |p| p.name == 'event_id' }
        param&.value
      end

      activities_by_event_id.delete(nil)

      activities_by_event_id.values.map do |activity_group|
        Utils::Warehouse::Workspace::CalendarEventsFormatter.new(activity_group).format
      end.compact
    end

    def error_response(message)
      { error: { message: message } }
    end
  end
end
