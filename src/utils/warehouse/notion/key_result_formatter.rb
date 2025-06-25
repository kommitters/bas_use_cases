# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion key_result records into a standardized hash format.
        class KeyResultFormatter < Base
          def format # rubocop:disable Metrics/MethodLength
            {
              external_key_result_id: extract_id,
              okr: extract_relation('OKR').first,
              key_result: extract_title('Key Result'),
              metric: extract_number('Metric'),
              current: extract_number('Current'),
              progress: extract_formula_number('Progress'),
              period: extract_rollup_value('Period'),
              objective: extract_rollup_value('Objective'),
              tags: extract_multi_select('Tags')
            }
          end
        end
      end
    end
  end
end
