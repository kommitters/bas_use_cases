# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Github
      ##
      # This class formats Github issue records into a standardized hash format,
      # inheriting extraction logic from the Base class to match the database schema.
      #
      class IssuesFormatter < Base
        ##
        # Formats the issue data by calling the extraction methods from the Base class.
        def format # rubocop:disable Metrics/MethodLength
          {
            external_github_issue_id: extract_id,
            github_user: extract_assignees_logins&.first, # Acting like external_person_id
            repository_id: extract_repository_id,
            milestone_id: extract_milestone_id,
            title: extract_title,
            state: extract_state,
            number: extract_number,
            assignees: format_pg_array(extract_assignees_logins),
            labels: format_pg_array(extract_labels_names)
          }
        end
      end
    end
  end
end
