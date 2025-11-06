# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Processes records.
        class ProcessFormatter < Base
          def format # rubocop:disable Metrics/MethodLength
            {
              external_process_id: @data['process_id'].to_s,
              external_org_unit_id: @data['owner_org_unit_id'],
              name: @data['name'],
              description: @data['description'],
              objective: @data['objective'],
              start_date: @data['start_date'],
              end_date: @data['end_date'],
              deadline: @data['deadline'],
              status: @data['status']
            }
          end
        end
      end
    end
  end
end
