# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion work item records into a standardized hash format.
        class ProjectFormatter < Base
          def format
            {
              external_project_id: extract_id,
              name: extract_title('Name'),
              type: extract_select('Project Type'),
              external_weekly_scope_id: extract_relation('Weekly Scope').first,
              external_domain_id: extract_relation('Domain').first
            }
          end
        end
      end
    end
  end
end
