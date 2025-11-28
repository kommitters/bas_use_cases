# frozen_string_literal: true

require 'time'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../utils/warehouse/github/releases_format'

module Implementation
  ##
  # Implementation::FetchReleasesFromGithub
  #
  # This class implements a bot that fetches releases from all repositories in a GitHub organization
  # and saves them into shared storage (e.g., PostgresDB).
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchReleasesFromGithub']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchReleasesFromGithub'
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
  #   Implementation::FetchReleasesFromGithub.new(options, shared_storage).execute
  #
  class FetchReleasesFromGithub < Bas::Bot::Base # rubocop:disable Metrics/ClassLength
    PER_PAGE = 100

    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      response = initialize_client
      return error_response(response) if response[:error]

      content = fetch_organization_content(response[:client])
      { success: { type: 'github_release', content: content } }
    end

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
    # Fetches releases from all repositories in the specified organization.
    #
    def fetch_organization_content(client)
      last_run = fetch_last_run_timestamp
      repositories = fetch_all_repositories(client)

      repositories.flat_map do |repo|
        fetch_repo_releases(client, repo, last_run).map do |release|
          format_release(release, repo)
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

    def fetch_last_run_timestamp
      read_result = @shared_storage_reader.read
      Time.parse(read_result.inserted_at.to_s) if read_result.inserted_at
    end

    ##
    # Initializes the GitHub client using provided credentials.
    #
    def initialize_client
      response = Utils::Github::OctokitClient.new(client_params).execute
      return response if response[:error]

      response[:client].auto_paginate = false
      response
    end

    ##
    # Fetches releases for a specific repository, considering the last run timestamp.
    #
    def fetch_repo_releases(client, repo, last_run)
      data = client.releases(repo.full_name, per_page: PER_PAGE)
      last_resp = client.last_response

      [].tap do |releases|
        loop do
          break if data.empty?

          releases.concat(filter_data(data, last_run))
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

    # Selects releases that are newer than the last run timestamp.
    def filter_data(data, last_run)
      return data if page_is_fresh?(data, last_run)

      data.select { |r| release_date(r) > last_run }
    end

    def page_is_fresh?(data, last_run)
      last_run.nil? || release_date(data.last) > last_run
    end

    def release_date(release)
      release[:published_at] || release[:created_at]
    end

    def format_release(release, repo)
      Utils::Warehouse::Github::ReleasesFormat.new(release, repo).format
    end

    # Paginates content and writes each page to the shared storage.
    def paginate_and_write(content)
      paged_entities = content.each_slice(PER_PAGE).to_a
      paged_entities.each_with_index do |page, idx|
        record = build_record(content: page, page_index: idx + 1, total_pages: paged_entities.size,
                              total_records: content.size)
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

    def normalize_response(releases, repo)
      releases.map { |release| Utils::Warehouse::Github::ReleasesFormat.new(release, repo).format }
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_release', content: content, page_index: page_index,
          total_pages: total_pages, total_records: total_records
        }
      }
    end

    def error_response(response)
      { error: { message: response[:error] } }
    end
  end
end
