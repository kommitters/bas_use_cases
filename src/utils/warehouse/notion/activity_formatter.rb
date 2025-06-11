# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion activity records into a standardized hash format.
        class ActivityFormatter < Base
          def format
            {
              external_activity_id: extract_id,
              name: extract_title('Name'),
              external_domain_id: extract_relation('Domain').first
            }
          end
        end
      end
    end
  end
end
