# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Github
      ##
      # Formats GitHub Repository data (from Discovery Bot) for the 'github_repositories' table.
      #
      class RepositoriesFormatter < Base
        ##
        # Returns the hash structure matching the database schema.
        #
        def format
          {
            external_repository_id: extract_id.to_s,
            name: extract_name,
            organization: extract_owner_login,
            url: extract_html_url,
            is_private: extract_is_private,
            is_archived: extract_is_archived,
            # We explicitly update the timestamp to indicate the record was processed
            updated_at: Time.now
          }
        end
      end
    end
  end
end
