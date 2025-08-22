# frozen_string_literal: true

require_relative 'base'
require 'securerandom'

module Utils
  module Warehouse
    module GoogleWorkspace
      ##
      # Class for formatting KPIs data from a Google Sheet row.
      # It extracts and maps the raw row data into a structured hash.
      #
      class KpisFormatter < Base
        # Main method that returns a hash with formatted KPI data.
        def format
          {
            external_kpi_id: @data[-1],
            description: @data[0],
            status: @data[-2],
            current_value: @data[3],
            target_value: @data[4],
            percentage: @data[5],
            name: @data[1].to_s.split(',').first.strip # domain name
          }
        end
      end
    end
  end
end
