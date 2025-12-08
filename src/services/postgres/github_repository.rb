# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # GithubRepository Service
    #
    # Manages the catalog of repositories and their synchronization status.
    # It provides methods to find stale repositories that need updates.
    #
    class GithubRepository < Services::Postgres::Base
      ATTRIBUTES = %i[external_repository_id name organization url is_private is_archived last_synced_issues_at
                      last_synced_releases_at last_synced_pull_requests_at].freeze

      TABLE = :github_repositories
      HISTORY_TABLE = :github_repositories_history
      HISTORY_FOREIGN_KEY = :github_repository_id

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'GithubRepository id is required to update' unless id

        transaction { update_item(TABLE, id, params) }
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
      rescue StandardError => e
        handle_error(e)
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      ##
      # Finds the repository that hasn't been synced for the longest time
      # for a specific entity type.
      #
      # @param organization [String] The organization name (e.g., 'kommitters')
      # @param entity_field [Symbol] The field to check (e.g., :last_synced_issues_at)
      #
      def find_next_to_sync(organization:, entity_field:)
        @db[TABLE]
          .where(organization: organization, is_archived: false)
          .order(Sequel.asc(entity_field).nulls_first) # NULLs first means new repos get priority
          .limit(1)
          .first
      end

      private

      def handle_error(error)
        puts "[GithubRepository Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
