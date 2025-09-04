# frozen_string_literal: true

require_relative 'base'
require_relative 'github_release'
require_relative 'github_issue'

module Services
  module Postgres
    ##
    # GithubPullRequest Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_pull_requests' table using the Base service.
    class GithubPullRequest < Services::Postgres::Base
      ATTRIBUTES = %i[external_github_pull_request_id repository_id release_id issue_id related_issue_ids reviews_data
                      title creation_date merge_date].freeze

      TABLE = :github_pull_requests
      HISTORY_TABLE = :github_pull_requests_history
      HISTORY_FOREIGN_KEY = :pull_request_id

      RELATIONS = [
        { service: GithubRelease, external: :external_github_release_id, internal: :release_id },
        { service: GithubIssue, external: :external_github_issue_id, internal: :issue_id }
      ].freeze

      def insert(params)
        assign_relations(params)

        transaction do
          insert_item(TABLE, params)
        end
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'GithubPullRequest id is required to update' unless id

        assign_relations(params)

        transaction do
          update_item(TABLE, id, params)
        end
      rescue StandardError => e
        handle_error(e)
      end

      def delete(id)
        transaction { delete_item(TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      def find(id)
        find_item(TABLE, id)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      def handle_error(error)
        puts "[GithubPullRequest Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
