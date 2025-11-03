# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX Organizational units records.
        class OrganizationalUnitFormatter < Base
          def format
            {
              external_org_unit_id: @data['org_unit_id'],
              name: @data['name'],
              status: @data['status']
            }
          end
        end
      end
    end
  end
end
