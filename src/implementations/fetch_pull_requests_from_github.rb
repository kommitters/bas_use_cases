# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../../src/utils/warehouse/github/pull_requests_format'

module Implementation
  ##
  # Implementation::FetchPullRequestsFromGithub
  #
  # This class implements a bot that fetches pull requests and their reviews
  # from all repositories in a GitHub organization.
  #
  class FetchPullRequestsFromGithub < Bas::Bot::Base
    PER_PAGE = 100

    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      client_response = initialize_client
      return client_response if client_response[:error]

      client = client_response[:client]
      repositories = fetch_repositories(client)
      all_pull_requests = fetch_all_pull_requests(client, repositories)

      { success: { type: 'github_pull_request', content: all_pull_requests } }
    end

    # Orchestrates the writing of processed data to the configured shared storage.
    #
    def write
      content = process_response.dig(:success, :content) || []
      return if content.empty?

      paginate_and_write(content)
    end

    private

    # Initializes the Octokit client and handles authentication.
    def initialize_client
      client_response = Utils::Github::OctokitClient.new(client_params).execute
      return client_response if client_response[:error]

      client = client_response[:client]
      client.auto_paginate = true
      { client: client }
    end

    # Fetches all repositories for the configured organization.
    def fetch_repositories(client)
      client.organization_repositories(process_options[:organization])
    end

    # Fetches all pull requests and their associated reviews for a given list of repositories.
    def fetch_all_pull_requests(client, repositories)
      all_prs = []
      repositories.each do |repo|
        # Fetching both open and closed pull requests
        pull_requests = client.pull_requests(repo.full_name, state: 'all', per_page: PER_PAGE)
        puts pull_requests.inspect
        pull_requests.each do |pr|
          # For each PR, fetch its reviews (this is an extra API call)
          reviews = client.pull_request_reviews(repo.full_name, pr.number)
          all_prs << normalize_response(pr, repo, reviews)
        end
      end
      all_prs
    end

    # Paginates content and writes each page to the shared storage.
    def paginate_and_write(content)
      paged_entities = content.each_slice(PER_PAGE).to_a
      paged_entities.each_with_index do |page, idx|
        record = build_record(
          content: page,
          page_index: idx + 1,
          total_pages: paged_entities.size,
          total_records: content.size
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

    def normalize_response(pull_request, repo, reviews)
      Utils::Warehouse::Github::PullRequestsFormat.new(pull_request, repo, reviews).format
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_pull_request',
          content: content,
          page_index: page_index,
          total_pages: total_pages,
          total_records: total_records
        }
      }
    end
  end
end
