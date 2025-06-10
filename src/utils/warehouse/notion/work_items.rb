# frozen_string_literal: true

require_relative 'base'

module Formatter
  ##
  # This class formats Notion work item records into a standardized hash format.
  class WorkItemFormatter
    def format(notion_record) # rubocop:disable Metrics/MethodLength
      base = Utils::Warehouse::Notion::Base.new(notion_record)
      {
        external_work_item_id: base.extract_id,
        name: base.extract_title('Detail'),
        external_project_id: base.extract_relation('Project').first,
        external_activity_id: base.extract_relation('Activity').first,
        external_domain_id: base.extract_relation('Activity domain').first,
        external_weekly_scope_id: base.extract_relation('Weekly Scope').first,
        work_item_status: base.extract_select('Status'),
        work_item_completion_date: base.extract_rich_text('Completion Date')
      }
    end
  end
end
