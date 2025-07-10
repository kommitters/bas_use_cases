# frozen_string_literal: true

module Utils
  module Warehouse
    module Github
      ##
      # Base class for Github data extraction.
      # This class provides methods to extract various types of data from Octokit resources.
      #
      class Base
        def initialize(github_data, repository)
          @data = github_data
          @repo = repository
        end

        def extract_id
          @data.id
        end

        def extract_html_url
          @data.html_url
        end

        def extract_tag_name
          @data.tag_name
        end

        def extract_name
          @data.name
        end

        def extract_body
          @data.body
        end

        def extract_published_at
          @data.published_at
        end

        def extract_created_at
          @data.created_at
        end

        def extract_is_prerelease
          @data.prerelease
        end

        def extract_author_login
          @data.author&.login
        end

        def extract_repository_id
          @repo.id
        end
      end
    end
  end
end
