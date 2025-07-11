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

        def extract_tag_name
          @data.tag_name
        end

        def extract_name
          @data.name
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

        def extract_repository_id
          @repo.id
        end

        def extract_milestone_id
          @data.milestone&.id
        end

        def extract_assignees_logins
          @data.assignees&.map(&:login)
        end

        def extract_labels_names
          @data.labels&.map(&:name)
        end

        def format_pg_array(array)
          return nil if array.nil? || array.empty?

          "{#{array.map(&:to_s).join(',')}}"
        end
      end
    end
  end
end
