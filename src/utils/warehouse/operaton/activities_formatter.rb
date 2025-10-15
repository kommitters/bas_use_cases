# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Operaton
      module Formatter
        # This class formats APEX domain records.
        class ActivitiesFormatter < Base
          def format
            {
              external_activity_id: @data['id'], external_process_id: @data['processInstanceId'],
              process_definition_key: @data['processDefinitionKey'],
              activity_id: @data['activityId'], activity_name: @data['activityName'],
              activity_type: @data['activityType'],
              task_id: @data['taskId'],
              assignee: @data['assignee'],
              start_time: @data['startTime'], end_time: @data['endTime'],
              duration_in_millis: @data['durationInMillis']
            }
          end
        end
      end
    end
  end
end
