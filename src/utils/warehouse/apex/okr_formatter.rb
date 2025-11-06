# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX OKRs records.
        class OkrFormatter < Base
          def format
            {
              external_okr_id: @data['id'].to_s,
              code: @data['code'],
              status: @data['status'],
              objective: @data['objective']
            }
          end
        end
      end
    end
  end
end
