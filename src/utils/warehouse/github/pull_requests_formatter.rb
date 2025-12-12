# frozen_string_literal: true

require_relative 'base'
require_relative '../../../services/postgres/github_issue'

module Utils
  module Warehouse
    module Github
      ##
      # This class formats Github Pull Request records into a standardized hash format,
      # inheriting extraction logic from the Base class to match the database schema.
      #
      class PullRequestsFormatter < Base
        ##
        # Formats the pull request data.
        def format # rubocop:disable Metrics/MethodLength
          {
            external_github_pull_request_id: extract_id,
            github_username: extract_user_login,
            external_github_release_id: extract_release_id,
            repository_id: extract_repository_id,
            issue_id: extract_related_issue_external_ids.first,
            related_issue_ids: format_pg_array(extract_related_issue_numbers),
            reviews_data: format_reviews_as_json,
            title: extract_title,
            creation_date: extract_created_at,
            merge_date: extract_merged_at
          }.compact
        end

        private

        def filtered_reviews
          @filtered_reviews ||= (@context[:reviews] || []).reject { |review| bot_user?(review) }
        end

        def format_reviews_as_json
          return nil if filtered_reviews.empty?

          filtered_reviews.map { |review| build_review_hash(review) }.to_json
        end

        def extract_related_issue_numbers
          body = extract_body
          return [] if body.nil? || body.empty?

          body.scan(/#(\d+)/).flatten.map(&:to_i).uniq
        end

        def extract_related_issue_external_ids # rubocop:disable Metrics/MethodLength
          numbers = extract_related_issue_numbers
          return [] if numbers.empty?

          first_number = numbers.first

          issue_service = Services::Postgres::GithubIssue.new(@context[:db])

          results = issue_service.query(
            repository_id: @context[:repository_id],
            number: first_number
          )

          results.map { |issue| issue[:id] }
        rescue StandardError => e
          puts "Error fetching related issue IDs via Service: #{e.message}"
          []
        end

        def extract_release_id
          @data.dig(:milestone, :id) || @data.dig('milestone', 'id')
        end

        def build_review_hash(review)
          {
            id: review[:id],
            user_login: extract_login_from(review),
            state: review[:state],
            body: review[:body],
            submitted_at: review[:submitted_at],
            comments_count: review[:comments]&.size || 0,
            comments: [] # Empty array as per requirement
          }
        end

        def extract_login_from(item)
          item.dig(:user, :login) || item.dig('user', 'login')
        end

        def bot_user?(item)
          login = extract_login_from(item)
          return true unless login # Si no hay login, lo tratamos como inválido/bot

          login.to_s.downcase == 'coderabbitai[bot]' || login.to_s.include?('[bot]')
        end
      end
    end
  end
end
