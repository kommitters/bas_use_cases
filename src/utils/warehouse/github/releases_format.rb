# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Github
      ##
      # This class formats Github release records into a standardized hash format,
      # inheriting extraction logic from the Base class, to match the database schema.
      #
      class ReleasesFormat < Base
        ##
        # Formats the release data by calling the extraction methods from the Base class.
        #
        def format
          {
            external_github_release_id: extract_id.to_s,
            repository_id: extract_repository_id,
            name: extract_name,
            tag_name: extract_tag_name,
            is_prerelease: extract_is_prerelease,
            creation_timestamp: extract_created_at,
            published_timestamp: extract_published_at
          }
        end
      end
    end
  end
end
