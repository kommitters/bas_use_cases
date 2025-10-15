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
              external_activity_id: @data['id'], process_definition_key: @data['processDefinitionKey'],
              process_instance_id: @data['processInstanceId'],
              task_definition_key: @data['taskDefinitionKey'],
              name: @data['name'], assignee: @data['assignee'],
              owner: @data['owner'], group: @data['group'],
              task_state: @data['taskState'],
              start_time: @data['startTime'], end_time: @data['endTime'],
              duration_in_millis: @data['durationInMillis']
            }
          end
        end
      end
    end
  end
end
