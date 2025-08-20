# frozen_string_literal: true

require_relative 'base'
require 'securerandom'

module Utils
  module Warehouse
    module GoogleWorkspace
      ##
      # Class for formatting Key Results data from a Google Sheet row.
      # It extracts and maps the raw row data into a structured hash.
      #
      class KeyResultsFormatter < Base
        # Main method that returns a hash with formatted key result data.
        def format
          {
            external_key_result_id: SecureRandom.uuid,
            okr: @data[0],
            key_result: @data[2],
            metric: @data[15],
            current: last_present_value,
            progress: last_present_value,
            # progress: last_present_value.to_s.strip == '-' ? 0 : metric_value,
            period: Time.now.year.to_s,
            objective: @data[0]
          }
        end

        private

        # Finds the last non-empty value in the monthly columns (indices 3 to 14).
        def last_present_value
          # @data represents the single row passed during initialization.
          monthly_values = @data[3..14]
          last_value = monthly_values.reverse.find { |val| !val.to_s.strip.empty? }

          return 0 if last_value.to_s.strip == '-' || last_value.nil?

          last_value
        end
      end
    end
  end
end
