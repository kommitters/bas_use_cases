# frozen_string_literal: true

require_relative 'base'

module Formatter
  ##
  # This class formats Notion project records into a standardized hash format.
  # It extracts relevant fields such as external_project_id, name, type, and relations.
  class ProjectFormatter
    def format(notion_record)
      base = Utils::Warehouse::Notion::Base.new(notion_record)
      {
        external_project_id: base.extract_id,
        name: base.extract_title('Name'),
        type: base.extract_select('Project Type'),
        external_weekly_scope_id: base.extract_relation('Weekly Scope').first,
        external_domain_id: base.extract_relation('Domain').first
      }
    end
  end
end
