# frozen_string_literal: true

require 'time'

module Utils
  module Warehouse
    module GoogleWorkspace
      ##
      # Base class for handling Google Workspace activity data.
      # This class provides methods to extract and manipulate activity data
      # from Google Workspace reports
      class Base
        # Constant for the .NET epoch (Time.utc(1,1,1)), used as the reference point
        # for time values expressed as seconds since year 0001-01-01.
        DOTNET_EPOCH = Time.utc(1, 1, 1)

        def initialize(activity_data, context = {})
          @data = activity_data
          @context = context
        end

        protected

        def extract_event_by_name(name)
          @data.flat_map { |activity| activity['events'] || [] }.find { |event| event['name'] == name }
        end

        def extract_parameter_value(params, name)
          params&.find { |p| p['name'] == name }&.dig('value')
        end

        def extract_time_from_param(param)
          int_value = param&.dig('intValue')
          return nil unless int_value

          (DOTNET_EPOCH + int_value.to_i).to_datetime
        end

        def calculate_duration(start_time, end_time)
          return 0 unless start_time && end_time

          ((end_time - start_time) * 24 * 60).to_i
        end

        def extract_creation_timestamp
          @data.first&.dig('id', 'time')
        end
      end
    end
  end
end
