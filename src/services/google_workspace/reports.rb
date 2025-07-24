# frozen_string_literal: true

require_relative 'base'
require 'google/apis/admin_reports_v1'

module Service
  module GoogleWorkspace
    ##
    # Service class to interact with the Google Workspace Admin Reports API.
    # It fetches audit activity logs for various applications, like Calendar.
    #
    class Reports < Base
      attr_reader :service

      ##
      # Initializes the Reports service.
      def initialize(config)
        scope = Google::Apis::AdminReportsV1::AUTH_ADMIN_REPORTS_AUDIT_READONLY
        super(config, scope: scope)
        @service = build_service
      end

      # Fetches all calendar audit activities from a specified start time.
      # This method automatically handles pagination to retrieve all available records.
      def fetch_calendar_activities(start_time:)
        all_activities = []
        page_token = nil

        loop do
          response = @service.list_activities(
            'all',
            'calendar',
            page_token: page_token,
            start_time: start_time.iso8601
          )

          all_activities.concat(response.items || [])
          page_token = response.next_page_token
          break unless page_token
        end

        { success: { activities: all_activities } }
      rescue Google::Apis::Error => e
        { error: { message: e.message, status_code: e.status_code } }
      end

      private

      # Builds and configures the Google::Apis::AdminReportsV1::ReportsService instance.
      def build_service
        service = Google::Apis::AdminReportsV1::ReportsService.new
        service.authorization = @credentials
        service
      end
    end
  end
end