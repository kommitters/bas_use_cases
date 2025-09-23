# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../../src/utils/warehouse/github/repositories_formatter'

module Implementation
  ##
  # Implementation::FetchRepositoriesFromGithub
  #
  # This class implements a bot that fetches repositories from all repositories in a GitHub organization
  # and saves them into shared storage (e.g., PostgresDB).
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchRepositoriesFromGithub']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchRepositoriesFromGithub'
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
  #   Implementation::FetchRepositoriesFromGithub.new(options, shared_storage).execute
  #
  class FetchRepositoriesFromGithub < Bas::Bot::Base
    PER_PAGE = 100

    # Orchestrates the fetching and formatting of records from GitHub.
    #
    def process
      client_response = initialize_client
      return error_response(client_response) if client_response[:error]

      client = client_response[:client]
      repositories = fetch_repositories(client)

      { success: { type: 'github_repository', content: repositories } }
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

    # Initializes the Octokit client and handles authentication.
    def initialize_client
      client_response = Utils::Github::OctokitClient.new(client_params).execute
      return client_response if client_response[:error]

      client = client_response[:client]
      { client: client }
    end

    # Fetches all repositories for the configured organization.
    def fetch_repositories(client)
      repositories = client.organization_repositories(process_options[:organization])

      normalize_response(repositories)
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

    def normalize_response(repositories)
      repositories.map { |repository| Utils::Warehouse::Github::RepositoriesFormatter.new(repository, nil).format }
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_repository',
          content: content,
          page_index: page_index,
          total_pages: total_pages,
          total_records: total_records
        }
      }
    end

    def error_response(response)
      { error: { message: response[:error] } }
    end
  end
end
