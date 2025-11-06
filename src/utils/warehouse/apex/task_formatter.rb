# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Tasks records.
        class TaskFormatter < Base
          def format # rubocop:disable Metrics/MethodLength
            {
              external_task_id: @data['task_id'].to_s,
              external_process_id: @data['process_id'],
              external_milestone_id: @data['milestone_id_raw'],
              name: @data['name'],
              description: @data['description'],
              status: @data['status'],
              assigned_to: @data['assigned_to'],
              start_date: @data['start_date'],
              end_date: @data['end_date'],
              deadline: @data['deadline']
            }
          end
        end
      end
    end
  end
end
