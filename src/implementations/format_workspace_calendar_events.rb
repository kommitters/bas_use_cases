# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../utils/warehouse/google_workspace/calendar_events_format'

module Implementation
  ##
  # FormatWorkspaceCalendarEvents bot implementation.
  # This bot fetches calendar events for all users in the Google Workspace domain.
  # It uses the Google Calendar API to retrieve events and formats them for storage.
  #
  class FormatWorkspaceCalendarEvents < Bas::Bot::Base
    def process
      all_activities = process_options[:calendar_events]

      unless all_activities.is_a?(Array) && !all_activities.empty?
        return error_response('Input data must be a non-empty Array.')
      end

      formatted_events = normalize_response(all_activities)
      { success: { type: 'calendar_event', content: formatted_events } }
    end

    private

    def normalize_response(activities)
      activities_by_event_id = (activities || []).group_by { |activity| extract_event_id_from(activity) }

      activities_by_event_id.delete(nil)

      activities_by_event_id.values.map do |activity_group|
        Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter.new(activity_group).format
      end.compact
    end

    def extract_event_id_from(activity)
      event = activity.dig('events', 0)
      param = event&.dig('parameters')&.find { |p| p['name'] == 'event_id' }
      param&.dig('value')
    end

    def error_response(message)
      { error: { message: message } }
    end
  end
end
