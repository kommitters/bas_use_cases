# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Github
      ##
      # This class formats Github Pull Request records into a standardized hash format,
      # inheriting extraction logic from the Base class to match the database schema.
      #
      class PullRequestsFormat < Base
        ##
        # Formats the pull request data.
        #
        # @return [Hash] The formatted pull request data.
        #
        def format
          {
            external_github_pull_request_id: extract_id,
            repository_id: extract_repository_id,
            external_issue_id: extract_issue_number_from_url, # For later lookup
            related_issue_ids: format_pg_array(extract_related_issue_ids),
            reviews_data: format_reviews_as_json,
            title: extract_title,
            creation_date: extract_created_at,
            merge_date: extract_merged_at
            # release_id is left out as it's not directly available on the PR object
            # and will be associated later.
          }
        end
      end
    end
  end
end
