# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/github/octokit_client'
require 'time'
require_relative '../utils/warehouse/github/issues_formatter'
require_relative '../services/postgres/github_repository'

module Implementation
  ##
  # Implementation::FetchIssuesFromGithub
  #
  # This bot acts as a "Worker" in the new architecture. Instead of iterating through
  # every repository in the organization, it asks the database for the *next* repository
  # that needs synchronization (the one with the oldest sync timestamp).
  #
  # It fetches only issues modified since the last run for that specific repository,
  # preventing memory overloads and API rate limiting.
  #
  # <b>Usage Example</b>
  #
  #   options = {
  #     private_pem: Config::GITHUB_PRIVATE_PEM,
  #     app_id: Config::GITHUB_APP_ID,
  #     organization: Config::KOMMITERS_ORGANIZATION
  #   }
  #
  #   Implementation::FetchIssuesFromGithub.new(options, shared_storage).execute
  #
  class FetchIssuesFromGithub < Bas::Bot::Base
    PER_PAGE = 100
    DEFAULT_SINCE = Time.now - (365 * 2 * 24 * 60 * 60)

    def process
      repo_service = Services::Postgres::GithubRepository.new(process_options[:db_connection])

      repo_record = repo_service.find_next_to_sync(
        organization: process_options[:organization],
        entity_field: :last_synced_issues_at
      )

      return { success: { message: 'All repositories are up to date.' } } unless repo_record

      stats = process_repository(repo_record)

      {
        success: { type: 'github_issue', content: stats[:content], repo_processed: repo_record }
      }
    end

    ##
    # Writes the processed data to the warehouse_sync table AND updates the
    # repository's synchronization timestamp in the master table.
    #
    def write
      response = process_response
      return if response[:error] || response.dig(:success, :repo_processed).nil?

      content = response.dig(:success, :content) || []
      repo = response.dig(:success, :repo_processed)

      paginate_and_write(content) unless content.empty?

      repo_service = Services::Postgres::GithubRepository.new(process_options[:db_connection])
      repo_service.update_sync_timestamp(repo[:id], :last_synced_issues_at, Time.now)
    end

    private

    ##
    # Initializes the Octokit client.
    #
    def initialize_client
      Utils::Github::OctokitClient.new(client_params).execute
    end

    ##
    # Orchestrates the fetching and formatting for a single repository.
    #
    def process_repository(repo)
      client_response = initialize_client
      return { content: [] } if client_response[:error]

      client = client_response[:client]
      repo_full_name = "#{repo[:organization]}/#{repo[:name]}"

      # Determine "Since" cursor
      since_date = repo[:last_synced_issues_at] || DEFAULT_SINCE

      # Fetch only what changed since last time
      raw_issues = fetch_issues_from_api(client, repo_full_name, since_date)

      formatted_issues = normalize_response(raw_issues, repo)

      { content: formatted_issues }
    end

    ##
    # Fetches issues from the API using the native 'since' filter.
    #
    def fetch_issues_from_api(client, repo_full_name, since_date)
      options = { state: 'all', since: since_date.iso8601, per_page: PER_PAGE }

      # Auto-pagination is safe here because 'since' limits the dataset significantly
      client.auto_paginate = true
      issues = client.list_issues(repo_full_name, options)
      client.auto_paginate = false

      issues
    end

    ##
    # Maps raw Octokit objects to the database schema using the Formatter.
    #
    def normalize_response(issues, repo)
      issues.filter_map do |issue_data|
        next unless issue?(issue_data)

        # We pass the Local Repo UUID (repo[:id]) to the formatter
        Utils::Warehouse::Github::IssuesFormatter.new(
          issue_data,
          { repository_id: repo[:id] }
        ).format
      end
    end

    ##
    # Splits content into pages and writes to shared storage.
    #
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

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_issue',
          content: content,
          page_index: page_index,
          total_pages: total_pages,
          total_records: total_records
        }
      }
    end

    def client_params
      {
        private_pem: process_options[:private_pem],
        app_id: process_options[:app_id],
        organization: process_options[:organization]
      }
    end

    def error_response(response)
      { error: { message: response[:error] } }
    end

    def issue?(issue_data)
      issue_data[:pull_request].nil?
    end
  end
end
