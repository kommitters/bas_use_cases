# frozen_string_literal: true

require_relative './base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        #
        # Formats records from the "Hired" database using pre-fetched warehouse data.
        class HiredPersonFormatter < Base
          # Formats a list of Notion records.
          def format
            {
              external_person_id: extract_id,
              full_name: extract_title('Name'),
              email_address: extract_email('Email'),
              hire_date: extract_date('Beginning Date'),
              exit_date: extract_date('End Date'),
              role: extract_select('Role'),
              external_domain_id: extract_relation('Domains').first
            }
          end
        end
      end
    end
  end
end
