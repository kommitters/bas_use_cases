# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Github Repository Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_repositories' table using the Base service.
    class GithubRepository < Services::Postgres::Base
      ATTRIBUTES = %i[external_github_repository_id name].freeze

      TABLE = :github_repositories

      def insert(params)
        puts "Inserting Github Repository: #{params}"
      end

      def update(id, params)
        puts "Updating Github Repository: #{params}"
      end

      def delete(id)
        puts "Deleting Github Repository: #{id}"
      end

      def find(id)
        puts "Finding Github Repository: #{id}"
      end

      def query(conditions = {})
        puts "Querying Github Repository: #{conditions}"
      end

      private

      def handle_error(error)
        puts "[GithubRepository Service ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
