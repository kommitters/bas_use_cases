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
              okr: extract_relation('OKR'),
              key_result: extract_relation('Key Result'),
              metric: extract_number('Metric'),
              current: extract_number('Current'),
              progress: extract_number('Progress'),
              period: extract_multi_select('Period'),
              objective: extract_relation('Objective')
            }
          end
        end
      end
    end
  end
end
