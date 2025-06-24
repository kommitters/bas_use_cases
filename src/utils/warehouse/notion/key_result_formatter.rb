# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion key_result records into a standardized hash format.
        class KeyResultFormatter < Base
          def format
            {
              external_key_results_id: extract_id,
              okr: extract_relation('OKR').first,
              key_result: extract_title('Key Result'),
              metric: extract_number('Metric'),
              current: extract_number('Current'),
              progress: extract_formula_number('Progress'),
              period: extract_rich_text('Period'),
              objective: extract_rich_text('Objective')
            }
          end
        end
      end
    end
  end
end
