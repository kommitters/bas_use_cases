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
        def format # rubocop:disable Metrics/MethodLength
          {
            external_github_pull_request_id: extract_id,
            repository_id: extract_repository_id,
            external_github_issue_id: extract_related_issues&.first,
            external_github_release_id: extract_release_id,
            related_issue_ids: format_pg_array(extract_related_issues),
            reviews_data: format_reviews_as_json,
            title: extract_title,
            creation_date: extract_created_at,
            merge_date: extract_merged_at
          }
        end
      end
    end
  end
end
