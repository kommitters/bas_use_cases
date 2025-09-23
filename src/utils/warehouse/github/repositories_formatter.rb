# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Github
      ##
      # This class formats Github release records into a standardized hash format,
      # inheriting extraction logic from the Base class, to match the database schema.
      #
      class RepositoriesFormatter < Base
        ##
        # Formats the release data by calling the extraction methods from the Base class.
        #
        def format # rubocop:disable Metrics/MethodLength
          {
            external_github_repository_id: extract_id,
            name: extract_name,
            language: extract_string(:language),
            description: extract_string(:description),
            html_url: extract_string(:html_url),

            is_private: extract_boolean(:private),
            is_fork: extract_boolean(:fork),
            is_archived: extract_boolean(:archived),
            is_disabled: extract_boolean(:disabled),

            watchers_count: extract_number(:watchers_count),
            stargazers_count: extract_number(:stargazers_count),
            forks_count: extract_number(:forks_count),

            created_at: extract_created_at
          }
        end
      end
    end
  end
end
