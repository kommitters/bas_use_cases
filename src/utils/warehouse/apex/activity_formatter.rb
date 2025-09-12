# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX activity records.
        class ActivityFormatter < Base
          def format
            {
              external_activity_id: @data['activity_id'].to_s,
              name: @data['name'],
              external_domain_id: @data['domain_id']
            }
          end
        end
      end
    end
  end
end
