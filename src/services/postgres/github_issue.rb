# frozen_string_literal: true

require_relative 'base'
require_relative 'person'

module Services
  module Postgres
    ##
    # GithubIssue Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_issues' table using the Base service.
    class GithubIssue < Services::Postgres::Base
      ATTRIBUTES = %i[external_github_issue_id person_id title state number repository_id milestone_id assignees
                      labels].freeze

      TABLE = :github_issues
      HISTORY_TABLE = :github_issues_history
      HISTORY_FOREIGN_KEY = :issue_id

      RELATIONS = [
        { service: Person, external: :github_user, internal: :person_id }
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
        raise ArgumentError, 'GithubIssue id is required to update' unless id

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
        puts "[GithubIssue Service ERROR] #{error.class}: #{error.message}\nBacktrace: #{error.backtrace.join("\n")}"
        raise error
      end
    end
  end
end
