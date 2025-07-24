# frozen_string_literal: true

require 'time'

module Utils
  module Warehouse
    module Workspace
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
          @data.flat_map(&:events).find { |event| event.name == name }
        end

        def extract_parameter_value(params, name)
          params&.find { |p| p.name == name }&.value
        end
        
        # Converts the param's int_value (assumed to be in seconds since the .NET epoch)
        # into a Ruby DateTime object.
        def extract_time_from_param(param)
          return nil unless param&.int_value

          # Adding an integer to a Time object in Ruby treats the integer as seconds.
          # We then convert the result to a DateTime.
          (DOTNET_EPOCH + param.int_value).to_datetime
        end

        # Calculates the duration in minutes between two DateTime objects.
        def calculate_duration(start_time, end_time)
          return 0 unless start_time && end_time
          
          ((end_time - start_time) * 24 * 60).to_i
        end

        def extract_creation_timestamp
          @data.first&.id&.time
        end
      end
    end
  end
end
