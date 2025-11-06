# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Weekly Scopes Tasks records.
        class WeeklyScopeTaskFormatter < Base
          def format
            {
              external_weekly_scope_task_id: @data['id'].to_s,
              external_weekly_scope_id: @data['weekly_scope_id'],
              external_task_id: @data['task_id']
            }
          end
        end
      end
    end
  end
end
