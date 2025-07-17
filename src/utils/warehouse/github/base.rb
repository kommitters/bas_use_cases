# frozen_string_literal: true

require 'sequel'
require 'json'

module Utils
  module Warehouse
    module Github
      ##
      # Base class for formatting GitHub API data.
      #
      # This class provides a set of methods to extract and format data from
      # GitHub API responses (as hashes) into a standardized structure. It is designed
      # to be inherited by more specific formatters (e.g., for Pull Requests, Issues).
      #
      class Base
        ##
        # Initializes the formatter with the main GitHub data object and an optional context hash.
        #
        def initialize(github_data, repository, context = {})
          @data = github_data
          @repo = repository
          @reviews = context[:reviews]
          @comments = context[:comments]
          @related_issues = context[:related_issues]
          @releases = context[:releases]
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
          @repo&.[](:id)
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
          @data[:merged_at]
        end

        def extract_title
          @data[:title]
        end

        def extract_related_issues
          return [] if @related_issues.nil? || @related_issues.empty?

          @related_issues.map { |issue| issue[:id] }
        end

        def extract_release_id
          return nil if @data[:merged_at].nil? || @releases.nil? || @releases.empty?

          # Find the first release published *after* the PR was merged.
          found_release = @releases.reverse.find { |release| release[:published_at] > @data[:merged_at] }
          found_release&.[](:id)
        end

        def format_reviews_as_json
          return nil if @reviews.nil? || @reviews.empty?

          comments_by_review_id = group_comments_by_review_id
          formatted_reviews = @reviews.map do |review|
            review_comments = comments_by_review_id[review[:id]] || []
            build_review_hash(review, review_comments)
          end
          formatted_reviews.to_json
        end

        def format_pg_array(array)
          return nil if array.nil? || array.empty?

          "{#{array.map(&:to_s).join(',')}}"
        end

        private

        # Groups review comments by their parent review ID for efficient lookup.
        def group_comments_by_review_id
          (@comments || []).group_by { |c| c[:pull_request_review_id] }
        end

        # Builds the hash for a single review, including its formatted comments.
        def build_review_hash(review, comments)
          {
            id: review[:id],
            user_login: review.dig(:user, :login),
            state: review[:state],
            body: review[:body],
            submitted_at: review[:submitted_at],
            comments: comments.map { |comment| format_comment(comment) }
          }
        end

        # Formats a single comment into a standardized hash.
        def format_comment(comment)
          {
            id: comment[:id],
            user_login: comment.dig(:user, :login),
            body: comment[:body],
            created_at: comment[:created_at]
          }
        end
      end
    end
  end
end
