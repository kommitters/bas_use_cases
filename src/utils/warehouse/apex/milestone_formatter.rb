# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Milestones records.
        class MilestoneFormatter < Base
          def format # rubocop:disable Metrics/MethodLength
            {
              external_apex_milestone_id: @data['id'].to_s,
              external_kr_id: @data['kr_id'],
              name: @data['name'],
              description: @data['description'] || 'No description provided',
              milestone_order: @data['milestone_order'],
              percentage: @data['percentage'],
              completion_date: @data['completion_date'],
              is_completed: @data['is_completed'].to_i == 1,
              status: @data['status'],
              code: @data['code']
            }
          end
        end
      end
    end
  end
end
