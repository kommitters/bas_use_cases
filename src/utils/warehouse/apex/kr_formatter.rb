# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX KRs records.
        class KrFormatter < Base
          def format
            {
              external_kr_id: @data['id'].to_s,
              external_okr_id: @data['okr_id'],
              description: @data['description'],
              status: @data['status'],
              code: @data['code']
            }
          end
        end
      end
    end
  end
end
