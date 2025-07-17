# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../../src/utils/warehouse/github/pull_requests_format'

module Implementation
  ###
  # Implementation::FetchPullRequestsFromGithub
  #
  #  Implements a bot that fetches pull requests, their reviews, and all
  #  associated data from all repositories in a GitHub organization.
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchPullRequestsFromGithub']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchPullRequestsFromGithub'
  #   }
  #
  #   options = {
  #     private_pem: Config::GITHUB_PRIVATE_PEM,
  #     app_id: Config::GITHUB_APP_ID,
  #     organization: Config::KOMMITERS_ORGANIZATION
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FetchPullRequestsFromGithub.new(options, shared_storage).execute
  #
  class FetchPullRequestsFromGithub < Bas::Bot::Base
    # The number of items to fetch per page from the GitHub API.
    PER_PAGE = 100

    ##
    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      client_response = initialize_client
      return error_response(client_response) if client_response[:error]

      client = client_response[:client]
      repositories = fetch_repositories(client)
      releases_by_repo = fetch_and_organize_releases(client, repositories)
      all_pull_requests = fetch_all_pull_requests(client, repositories, releases_by_repo)

      { success: { type: 'github_pull_request', content: all_pull_requests } }
    end

    ##
    # Orchestrates the writing of processed data to the configured shared storage.
    #
    def write
      return @shared_storage_writer.write(process_response) if process_response[:error]

      content = process_response.dig(:success, :content) || []
      return if content.empty?

      paginate_and_write(content)
    end

    private

    ##
    # Initializes the Octokit client and handles authentication.
    #
    def initialize_client
      client_response = Utils::Github::OctokitClient.new(client_params).execute
      return client_response if client_response[:error]

      client = client_response[:client]
      client.auto_paginate = true
      { client: client }
    end

    ##
    # Fetches all repositories for the configured organization.
    #
    def fetch_repositories(client)
      client.organization_repositories(process_options[:organization])
    end

    ##
    # Fetches all releases for the given repositories and organizes them by repository ID.
    #
    def fetch_and_organize_releases(client, repositories)
      repositories.to_h do |repo|
        releases = client.releases(repo[:full_name])
        sorted_releases = releases.sort_by { |r| r[:published_at] }.reverse
        [repo[:id], sorted_releases]
      end
    end

    ##
    # Fetches all pull requests and their associated data for a list of repositories.
    #
    def fetch_all_pull_requests(client, repositories, releases_by_repo)
      repositories.flat_map do |repo|
        pull_requests = client.pull_requests(repo[:full_name], state: 'all', per_page: PER_PAGE)
        repo_releases = releases_by_repo[repo[:id]] || []

        pull_requests.map { |pr| process_pull_request(client, pr, repo, repo_releases) }
      end
    end

    def process_pull_request(client, pull_request, repo, repo_releases)
      context = {
        reviews: client.pull_request_reviews(repo[:full_name], pull_request[:number]),
        comments: client.pull_request_comments(repo[:full_name], pull_request[:number]),
        related_issues: fetch_related_issues(client, repo[:full_name], pull_request[:body]),
        releases: repo_releases
      }

      Utils::Warehouse::Github::PullRequestsFormat.new(pull_request, repo, context).format
    end

    ##
    # Extracts issue numbers from a PR body and fetches the full issue objects.
    #
    def fetch_related_issues(client, repo_full_name, pr_body)
      return [] if pr_body.nil?

      issue_numbers = pr_body.scan(/(?:closes|fixes|resolves|fix)\s+#(\d+)/i).flatten.map(&:to_i)
      return [] if issue_numbers.empty?

      issue_numbers.map { |n| find_issue(client, repo_full_name, n) }.compact
    end

    def paginate_and_write(content)
      paged_entities = content.each_slice(PER_PAGE).to_a
      paged_entities.each_with_index do |page, idx|
        record = build_record(
          content: page, page_index: idx + 1,
          total_pages: paged_entities.size, total_records: content.size
        )
        @shared_storage_writer.write(record)
      end
    end

    def client_params
      {
        private_pem: process_options[:private_pem],
        app_id: process_options[:app_id],
        organization: process_options[:organization]
      }
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_pull_request', content: content, page_index: page_index,
          total_pages: total_pages, total_records: total_records
        }
      }
    end

    def find_issue(client, repo_full_name, number)
      client.issue(repo_full_name, number)
    rescue Octokit::NotFound
      nil
    end

    def error_response(response)
      { error: { message: response[:error] } }
    end
  end
end
