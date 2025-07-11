# frozen_string_literal: true

require 'sequel'

module Utils
  module Warehouse
    module Github
      ##
      # Base class for Github data extraction.
      # This class provides methods to extract various types of data from Octokit resources.
      #
      class Base
        def initialize(github_data, repository = nil, reviews_data = nil)
          @data = github_data
          @repo = repository
          @reviews = reviews_data
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

        def extract_merged_at
          @data.merged_at
        end

        def extract_title
          @data.title
        end

        def extract_issue_number_from_url
          @data.issue_url&.split('/')&.last&.to_i
        end

        def extract_related_issue_ids
          return [] if @data.body.nil?

          @data.body.scan(/(?:closes|fixes|resolves)\s+#(\d+)/i).flatten.map(&:to_i)
        end

        def format_reviews_as_json
          return nil if @reviews.nil? || @reviews.empty?

          formatted_reviews = @reviews.map do |review|
            {
              id: review.id,
              user_login: review.user&.login,
              state: review.state,
              submitted_at: review.submitted_at
            }
          end
          Sequel.pg_jsonb(formatted_reviews)
        end

        def format_pg_array(array)
          return nil if array.nil? || array.empty?

          "{#{array.map(&:to_s).join(',')}}"
        end
      end
    end
  end
end
