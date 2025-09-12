# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX project records.
        class ProjectFormatter < Base
          def format
            {
              external_project_id: @data['project_id'].to_s,
              name: @data['name'],
              status: @data['project_status'],
              external_domain_id: @data['domain_id']
            }
          end
        end
      end
    end
  end
end
