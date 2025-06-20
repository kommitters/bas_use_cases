# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion domain records into a standardized hash format.
        class DomainFormatter < Base
          def format
            {
              external_domain_id: extract_id,
              name: extract_title('Name'),
              archived: extract_multi_select('Archived')
            }
          end
        end
      end
    end
  end
end
