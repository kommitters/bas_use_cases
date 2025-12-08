# frozen_string_literal: true

require 'sequel'
require 'json'
require 'time'

module Utils
  module Warehouse
    module Github
      ##
      # Base class for formatting GitHub API data.
      #
      # This class acts as a central library of extraction methods for GitHub objects
      # (Repositories, Issues, Pull Requests, Releases). It standardizes how we parse
      # dates, IDs, and arrays for the PostgreSQL database.
      #
      class Base
        ##
        # Initializes the formatter.
        #
        # @param github_data [Sawyer::Resource|Hash] The raw data from Octokit.
        # @param context [Hash] Additional context (e.g., repository_id, organization_name, related records).
        #
        def initialize(github_data, context = {})
          @data = github_data
          @context = context

          # Context conveniences
          @repository_id = context[:repository_id] # UUID from our DB
          @organization = context[:organization]
        end

        # -- Common Identity --

        def extract_id
          @data[:id]
        end

        def extract_node_id
          @data[:node_id]
        end

        # -- Repository Specifics --

        def extract_name
          @data[:name]
        end

        def extract_full_name
          @data[:full_name]
        end

        def extract_owner_login
          # If the payload has owner info, use it; otherwise fallback to context
          @data.dig(:owner, :login) || @organization
        end

        def extract_html_url
          @data[:html_url]
        end

        def extract_default_branch
          @data[:default_branch]
        end

        def extract_is_private
          @data[:private] || false
        end

        def extract_is_archived
          @data[:archived] || false
        end

        # -- Dates --

        def extract_created_at
          @data[:created_at]
        end

        def extract_updated_at
          @data[:updated_at]
        end

        def extract_published_at
          @data[:published_at]
        end

        def extract_merged_at
          @data[:merged_at]
        end

        def extract_closed_at
          @data[:closed_at]
        end

        # -- Issues / PRs Specifics --

        def extract_repository_fk
          @repository_id
        end

        def extract_number
          @data[:number]
        end

        def extract_title
          @data[:title]
        end

        def extract_body
          @data[:body]
        end

        def extract_state
          @data[:state]
        end

        def extract_user_login
          @data.dig(:user, :login)
        end

        def extract_milestone_id
          @data.dig(:milestone, :id)
        end

        # -- Arrays / Associations --

        def extract_assignees_logins
          return [] unless @data[:assignees]

          @data[:assignees].map { |u| u[:login] }
        end

        def extract_labels_names
          return [] unless @data[:labels]

          @data[:labels].map { |l| l[:name] }
        end

        # -- Helpers --

        # Formats a Ruby array into a PostgreSQL array string format: "{a,b,c}"
        def format_pg_array(array)
          return nil if array.nil? || array.empty?

          # Escape elements if necessary, though simple strings usually suffice
          "{#{array.map(&:to_s).join(',')}}"
        end

        # Formats a hash or array to a JSON string for JSONB columns
        def format_json(data)
          return nil if data.nil? || data.empty?

          data.to_json
        end
      end
    end
  end
end
