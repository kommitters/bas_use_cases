# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Weekly Scopes records.
        class WeeklyScopeFormatter < Base
          def format
            {
              external_weekly_scope_id: @data['weekly_id'].to_s,
              description: @data['name'],
              start_week_date: @data['start_date'],
              end_week_date: @data['end_date']
            }
          end
        end
      end
    end
  end
end
