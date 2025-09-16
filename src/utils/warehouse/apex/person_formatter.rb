# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX person records.
        class PersonFormatter < Base
          def format
            {
              external_person_id: @data['person_id'].to_s,
              full_name: @data['name'],
              email_address: @data['email'],
              role: @data['work_role_id'],
              external_domain_id: @data['domain_id']
            }
          end
        end
      end
    end
  end
end
