# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/github/octokit_client'
require 'time'
require_relative '../utils/warehouse/github/repositories_formatter'

module Implementation
  ##
  # The Implementation::FetchRepositoriesFromGithub class serves as a bot implementation to discover
  # repositories from a GitHub organization using an incremental fetch strategy and write them on
  # a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchRepositoriesFromGithubKommitters']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchRepositoriesFromGithubKommitters'
  #   }
  #
  #   options = {
  #     private_pem: Config::GITHUB_PRIVATE_PEM,
  #     app_id: Config::GITHUB_APP_ID,
  #     organization: 'kommitters'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FetchRepositoriesFromGithub.new(options, shared_storage).execute
  #
  class FetchRepositoriesFromGithub < Bas::Bot::Base
    PER_PAGE = 100
    # Default fallback date (10 years ago) if the bot has never run before
    DEFAULT_SINCE = Time.now - (365 * 10 * 24 * 60 * 60)

    def process
      client_response = initialize_client
      return error_response(client_response) if client_response[:error]

      client = client_response[:client]
      org = process_options[:organization]

      last_run_time = fetch_last_run_timestamp || DEFAULT_SINCE
      raw_repos = fetch_updated_repos(client, org, last_run_time)

      return { success: { message: "No repositories updated since #{last_run_time}" } } if raw_repos.empty?

      formatted_repos = normalize_response(raw_repos, org)

      { success: { type: 'github_repository', content: formatted_repos } }
    end

    ##
    # Writes the processed data to the warehouse_sync table.
    # It handles pagination to avoid inserting too large JSONB payloads.
    #
    def write
      return @shared_storage_writer.write(process_response) if process_response[:error]

      content = process_response.dig(:success, :content) || []
      return if content.empty?

      paginate_and_write(content)
    end

    private

    ##
    # Initializes the Octokit client with credentials.
    #
    def initialize_client
      Utils::Github::OctokitClient.new(client_params).execute
    end

    ##
    # Fetches the timestamp of the last successful run from shared storage.
    #
    def fetch_last_run_timestamp
      read_result = @shared_storage_reader.read
      return nil unless read_result&.inserted_at

      Time.parse(read_result.inserted_at.to_s)
    end

    ##
    # Fetches repositories sorted by update time and stops when hitting old data.
    #
    def fetch_updated_repos(client, org, cutoff_time) # rubocop:disable Metrics/MethodLength
      page = 1

      [].tap do |collected_repos|
        loop do
          batch = fetch_repo_page(client, org, page)
          break if batch.empty?

          fresh_batch = filter_fresh_repos(batch, cutoff_time)
          collected_repos.concat(fresh_batch)

          break if should_stop_fetching?(batch, fresh_batch, cutoff_time, client)

          page += 1
        end
      end
    end

    def fetch_repo_page(client, org, page)
      options = { type: 'all', sort: 'updated', direction: 'desc', per_page: PER_PAGE, page: page }
      client.organization_repositories(org, options)
    end

    def filter_fresh_repos(batch, cutoff_time)
      batch.select { |r| r[:updated_at] > cutoff_time }
    end

    def should_stop_fetching?(full_batch, fresh_batch, cutoff_time, client)
      # Stop if we filtered out some items (meaning we hit the time limit in this page)
      return true if fresh_batch.size < full_batch.size

      # Double check: Stop if the last item in the full batch is already old
      return true if full_batch.last[:updated_at] <= cutoff_time

      # Stop if there are no more pages
      !client.last_response.rels[:next]
    end

    ##
    # Maps raw Octokit objects to the database schema using the Formatter.
    #
    def normalize_response(repos, org)
      repos.map do |repo_data|
        Utils::Warehouse::Github::RepositoriesFormatter.new(
          repo_data,
          { organization: org }
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
          type: 'github_repository',
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
  end
end
