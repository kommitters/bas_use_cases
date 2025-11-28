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
  class FetchPullRequestsFromGithub < Bas::Bot::Base # rubocop:disable Metrics/ClassLength
    # The number of items to fetch per page from the GitHub API.
    PER_PAGE = 100

    ##
    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      response = initialize_client
      return error_response(response) if response[:error]

      content = fetch_organization_content(response[:client])
      { success: { type: 'github_pull_request', content: content } }
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
    # Fetches all pull requests across all repositories in the organization.
    #
    def fetch_organization_content(client)
      last_run = fetch_last_run_timestamp
      repositories = fetch_all_repositories(client)
      releases_map = fetch_releases_map(client, repositories)

      repositories.flat_map do |repo|
        fetch_repo_prs(client, repo, last_run).map do |pr|
          format_pr(client, pr, repo, releases_map[repo[:id]] || [])
        end
      end
    end

    ##
    # Fetches ALL repositories for the organization, handling pagination.
    #
    def fetch_all_repositories(client)
      page = 1
      [].tap do |repositories|
        loop do
          repos = client.organization_repositories(process_options[:organization], page: page, per_page: PER_PAGE)
          break if repos.empty?

          repositories.concat(repos)
          break unless client.last_response.rels[:next]

          page += 1
        end
      end
    end

    ##
    # Fetches the timestamp of the last successful run from shared storage.
    #
    def fetch_last_run_timestamp
      read_result = @shared_storage_reader.read
      Time.parse(read_result.inserted_at.to_s) if read_result.inserted_at
    end

    ##
    # Initializes the Octokit client and handles authentication.
    #
    def initialize_client
      response = Utils::Github::OctokitClient.new(client_params).execute
      return response if response[:error]

      response[:client].auto_paginate = false
      response
    end

    ##
    # Fetches a map of releases for each repository.
    #
    def fetch_releases_map(client, repositories)
      repositories.to_h do |repo|
        releases = client.releases(repo[:full_name])
        [repo[:id], releases.sort_by { |r| r[:published_at] }.reverse]
      end
    end

    ##
    # Fetches all pull requests for a given repository, considering the last run timestamp.
    #
    def fetch_repo_prs(client, repo, last_run)
      data = client.pull_requests(repo[:full_name], prs_api_params)
      last_resp = client.last_response

      [].tap do |prs|
        loop do
          break if data.empty?

          prs.concat(filter_data(data, last_run))
          break if stop_fetching?(data, last_run, last_resp)

          last_resp, data = fetch_next_page(last_resp)
        end
      end
    end

    def stop_fetching?(data, last_run, last_resp)
      !page_is_fresh?(data, last_run) || !last_resp.rels[:next]
    end

    def fetch_next_page(last_resp)
      resp = last_resp.rels[:next].get
      [resp, resp.data]
    end

    def filter_data(data, last_run)
      return data if page_is_fresh?(data, last_run)

      data.select { |pr| pr[:updated_at] > last_run }
    end

    def prs_api_params
      { state: 'all', sort: 'updated', direction: 'desc', per_page: PER_PAGE }
    end

    def page_is_fresh?(data, last_run)
      last_run.nil? || data.last[:updated_at] > last_run
    end

    def format_pr(client, pull_request, repo, releases)
      context = {
        reviews: client.pull_request_reviews(repo[:full_name], pull_request[:number]),
        comments: client.pull_request_comments(repo[:full_name], pull_request[:number]),
        related_issues: extract_related_issues(pull_request[:body]),
        releases: releases
      }
      Utils::Warehouse::Github::PullRequestsFormat.new(pull_request, repo, context).format
    end

    ##
    # Extracts issue numbers from a PR body and fetches the full issue objects.
    #
    def extract_related_issues(body)
      return [] if body.nil?

      body.scan(/(?:closes|fixes|resolves|fix|related)\s+#(\d+)/i).flatten.map(&:to_i)
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

    def error_response(response)
      { error: { message: response[:error] } }
    end
  end
end
