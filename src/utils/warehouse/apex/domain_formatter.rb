# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX domain records.
        class DomainFormatter < Base
          def format
            {
              external_domain_id: @data['domain_id'],
              name: @data['domain_id'],
              archived: @data['status'] == 'Archived'
            }
          end
        end
      end
    end
  end
end
