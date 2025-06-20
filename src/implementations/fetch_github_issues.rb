# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'

module Implementation
  ##
  # The Implementation::FetchGithubIssues class serves as a bot implementation to fetch GitHub issues from a
  # repository and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: repo_tag,
  #     where: "tag=$1 ORDER BY inserted_at DESC",
  #     params: [repo_tag]
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: repo_tag
  #   }
  #
  #   options = {
  #     private_pem: "Github App private token",
  #     app_id: "Github App id",
  #     repo: "repository name",
  #     filters: "hash with filters",
  #     organization: "GitHub organization name",
  #     domain: "notion domain",
  #     status: "notion status",
  #     work_item_type: "notion work item type",
  #     type_id: "work logs type id",
  #     connection:,
  #     db_table: "github_issues",
  #     tag: "GithubIssueRequest"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FetchGithubIssues.new(options, shared_storage).execute
  #
  class FetchGithubIssues < Bas::Bot::Base
    ISSUE_PARAMS = %i[id html_url title body number state created_at updated_at].freeze
    PER_PAGE = 100

    # Process function to request GitHub issues using the octokit utility
    #
    def process
      octokit = Utils::Github::OctokitClient.new(params).execute

      if octokit[:client]
        repo_issues = octokit[:client].issues(@process_options[:repo], filters)

        normalize_response(repo_issues).each { |issue| create_request(issue) }

        { success: { created: true } }
      else
        { error: octokit[:error] }
      end
    end

    private

    def params
      {
        private_pem: process_options[:private_pem],
        app_id: process_options[:app_id],
        method: process_options[:method],
        method_params: process_options[:method_params],
        organization: process_options[:organization]
      }
    end

    def filters
      default_filter = { per_page: PER_PAGE }

      filters = process_options[:filters]
      filters = filters.merge({ since: read_response.inserted_at }) unless read_response.nil?

      filters.is_a?(Hash) ? default_filter.merge(filters) : default_filter
    end

    def normalize_response(issues)
      issues.map do |issue|
        ISSUE_PARAMS.reduce({}) do |hash, param|
          hash.merge({ param => issue.send(param) })
              .merge({ assignees: issue.assignees.map(&:login) })
              .merge({ labels: issue.labels.map { |l| l.to_h.slice(:id, :name, :color, :description) } })
        end
      end
    end

    def create_request(issue)
      write_data = {
        success: {
          issue:,
          work_item_type: process_options[:work_item_type],
          type_id: process_options[:type_id],
          domain: process_options[:domain]
        }
      }

      Bas::SharedStorage::Postgres.new({ write_options: process_options }).write(write_data)
    end
  end
end
