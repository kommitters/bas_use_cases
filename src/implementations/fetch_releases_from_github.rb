# frozen_string_literal: true

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
  class FetchReleasesFromGithub < Bas::Bot::Base
    PER_PAGE = 100

    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      client_response = initialize_client
      return client_response if client_response[:error]

      client = client_response[:client]
      repositories = fetch_repositories(client)
      all_releases = fetch_all_releases(client, repositories)

      { success: { type: 'github_release', content: all_releases } }
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

    # Fetches all releases for a given list of repositories.
    def fetch_all_releases(client, repositories)
      all_releases = []
      repositories.each do |repo|
        releases = client.releases(repo.full_name, per_page: PER_PAGE)
        all_releases.concat(normalize_response(releases, repo))
      end
      all_releases
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

    def normalize_response(releases, repo)
      releases.map { |release| Utils::Warehouse::Github::ReleasesFormat.new(release, repo).format }
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_release',
          content: content,
          page_index: page_index,
          total_pages: total_pages,
          total_records: total_records
        }
      }
    end
  end
end
