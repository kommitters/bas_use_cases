# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Apex
      module Formatter
        # This class formats APEX person records.
        class PeopleFormatter < Base
          def format
            {
              external_person_id: @data['person_id'].to_s,
              full_name: @data['name'],
              email_address: @data['email'],
              job_title: @data['job_title'],
              is_active: person_status,
              github_username: @data['ghuser']
            }
          end
        end
      end
    end
  end
end
