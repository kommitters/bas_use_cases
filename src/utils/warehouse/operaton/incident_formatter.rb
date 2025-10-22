# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Operaton
      module Formatter
        # This class formats Operaton incident records.
        class IncidentFormatter < Base
          def format
            {
              external_incident_id: @data['id'], external_process_id: @data['processInstanceId'],
              process_definition_key: @data['processDefinitionKey'],
              activity_id: @data['activityId'],
              incident_type: @data['incidentType'],
              incident_message: @data['incidentMessage'],
              resolved: @data['resolved'],
              create_time: @data['createTime'],
              end_time: @data['endTime']
            }
          end
        end
      end
    end
  end
end
