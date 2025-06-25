# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion person records into a standardized hash format.
        class PersonFormatter < Base
          def format
            {
              external_person_id: extract_id,
              full_name: extract_title('Name'),
              email_address: extract_email('Email'),
              role: extract_select('Role'),
              notion_user_id: extract_people_id('Notion User'),
              external_domain_id: extract_relation('Domain').first
            }
          end
        end
      end
    end
  end
end
