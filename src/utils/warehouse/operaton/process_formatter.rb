# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Operaton
      module Formatter
        # This class formats APEX domain records.
        class ProcessFormatter < Base
          def format
            {
              id: @data['id'], business_key: @data['businessKey'],
              process_definition_key: @data['processDefinitionKey'],
              process_definition_name: @data['processDefinitionName'],
              start_time: @data['startTime'], end_time: @data['endTime'],
              duration_in_millis: @data['durationInMillis'],
              process_definition_version: @data['processDefinitionVersion'],
              state: @data['state']
            }
          end
        end
      end
    end
  end
end
