# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion weekly scope records into a standardized hash format.
        class WeeklyScopeFormatter < Base
          def format
            {
              external_weekly_scope_id: extract_id,
              description: extract_rich_text('Description'),
              start_week_date: extract_date('Start Week Data'),
              end_week_date: extract_date('End Week Data'),
              external_domain_id: extract_relation('Domain'),
              external_person_id: extract_relation('Person')
            }
          end
        end
      end
    end
  end
end
