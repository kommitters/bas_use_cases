# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion milestone records into a standardized hash format.
        class MilestoneFormatter < Base
          def format
            {
              external_milestone_id: extract_id,
              name: extract_title('Name'),
              status: extract_multi_select('Status'),
              completion_date: extract_date('Completion Date'),
              external_project_id: extract_relation('Project').first
            }
          end
        end
      end
    end
  end
end
