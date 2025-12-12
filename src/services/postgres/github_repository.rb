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
      # Finds the next repository to synchronize based on the specified criteria.
      # It selects the repository with the oldest synchronization timestamp for the given entity field,
      # optionally filtering by a dependency field.
      #
      def find_next_to_sync(organization:, entity_field:, dependency_field: nil)
        scope = @db[TABLE]
                .where(organization: organization, is_archived: false)

        scope = scope.exclude(dependency_field => nil) if dependency_field

        scope
          .order(
            Sequel.asc(entity_field, nulls: :first),
            Sequel.asc(:name)
          )
          .limit(1)
          .first
      end

      ##
      # Updates the synchronization timestamp for a specific entity on a repository.
      #
      def update_sync_timestamp(id, field, time)
        update(id, { field => time, updated_at: Time.now })
      end

      private

      def handle_error(error)
        puts "[GithubRepository Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
