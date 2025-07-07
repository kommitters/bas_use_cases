# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # GithubRelease Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_releases' table using the Base service.
    class GithubRelease < Services::Postgres::Base
      ATTRIBUTES = %i[external_github_release_id repository_id name tag_name is_prerelease creation_timestamp
                      published_timestamp].freeze

      TABLE = :github_releases

      def insert(params)
        transaction { insert_item(TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, 'GithubRelease id is required to update' unless id

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
        puts "[GithubRelease Service ERROR] #{error.class}: #{error.message}\nBacktrace: #{error.backtrace.join("\n")}"
        raise error
      end
    end
  end
end
