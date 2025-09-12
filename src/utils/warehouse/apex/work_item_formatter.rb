# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX work item records.
        class WorkItemFormatter < Base
          def format
            {
              external_work_item_id: @data['work_item_id'].to_s,
              name: @data['name'],
              status: @data['status'],
              completion_date: @data['completion_date'],
              description: @data['description'],
              external_project_id: @data['project_id'],
              external_activity_id: @data['activity_id'],
              external_domain_id: @data['domain_id']
            }
          end
        end
      end
    end
  end
end
