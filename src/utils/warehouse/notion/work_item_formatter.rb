# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion work item records into a standardized hash format.
        class WorkItemFormatter < Base
          def format
            {
              external_work_item_id: extract_id,
              name: extract_title('Detail'),
              external_project_id: extract_relation('Project').first,
              external_activity_id: extract_relation('Activity').first,
              external_domain_id: extract_relation('Responsible domain').first,
              external_weekly_scope_id: extract_relation('Weekly scope').first,
              work_item_status: extract_status('Status'),
              work_item_completion_date: extract_date('Date')
            }
          end
        end
      end
    end
  end
end
