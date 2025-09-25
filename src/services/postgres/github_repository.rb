# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Github Repository Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_repositories' table using the Base service.
    class GithubRepository < Services::Postgres::Base
      ATTRIBUTES = %i[external_github_repository_id name owner language description html_url
                      is_private is_fork is_archived is_disabled watchers_count stargazers_count forks_count
                      creation_timestamp].freeze

      TABLE = :github_repositories

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
      end

      def query(conditions = {})
        query_item(TABLE, conditions)
      end

      private

      def handle_error(error)
        puts "[GithubRepository Service ERROR] #{error.class}: #{error.message}"
        puts "Backtrace: #{error.backtrace.join("\n")}"
        raise error
      end
    end
  end
end
