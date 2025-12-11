# frozen_string_literal: true

require 'time'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../utils/warehouse/github/releases_formatter'
require_relative '../services/postgres/github_repository'

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
    DEFAULT_SINCE = Time.parse('2015-01-01')

    def process
      repo_service = Services::Postgres::GithubRepository.new(process_options[:db_connection])

      repo_record = repo_service.find_next_to_sync(
        organization: process_options[:organization],
        entity_field: :last_synced_releases_at
      )

      return { success: { message: 'All repositories are up to date.' } } unless repo_record

      stats = process_repository(repo_record)

      { success: { type: 'github_release', content: stats[:content], repo_processed: repo_record } }
    end

    def write
      response = process_response
      return if response[:error] || response.dig(:success, :repo_processed).nil?

      content = response.dig(:success, :content) || []
      repo = response.dig(:success, :repo_processed)

      paginate_and_write(content) unless content.empty?

      repo_service = Services::Postgres::GithubRepository.new(process_options[:db_connection])

      repo_service.update_sync_timestamp(repo[:id], :last_synced_releases_at, Time.now)
    end

    private

    def initialize_client
      Utils::Github::OctokitClient.new(client_params).execute
    end

    def process_repository(repo)
      client_response = initialize_client
      return { content: [] } if client_response[:error]

      client = client_response[:client]

      # Reconstruct full_name (organization/name)
      repo_full_name = "#{repo[:organization]}/#{repo[:name]}"

      cutoff_date = repo[:last_synced_releases_at] || DEFAULT_SINCE

      raw_releases = fetch_new_releases(client, repo_full_name, cutoff_date)
      formatted_releases = normalize_response(raw_releases, repo)

      { content: formatted_releases }
    end

    ##
    # Manually filters releases since the API doesn't support 'since'.
    #
    def fetch_new_releases(client, repo_full_name, cutoff_date) # rubocop:disable Metrics/MethodLength
      [].tap do |collected|
        page = 1

        loop do
          batch = client.releases(repo_full_name, per_page: PER_PAGE, page: page)
          break if batch.empty?

          fresh_batch = filter_releases_by_date(batch, cutoff_date)
          collected.concat(fresh_batch)

          # Stop if we found old data (fresh < batch) or no more pages exist
          break if stop_pagination?(client, batch, fresh_batch)

          page += 1
        end
      end
    end

    # Helper to filter a batch of releases based on the cutoff date
    def filter_releases_by_date(batch, cutoff_date)
      batch.select do |r|
        date = r[:published_at] || r[:created_at]
        date && date > cutoff_date
      end
    end

    def stop_pagination?(client, batch, fresh_batch)
      fresh_batch.size < batch.size || !client.last_response.rels[:next]
    end

    def normalize_response(releases, repo)
      releases.map do |release_data|
        Utils::Warehouse::Github::ReleasesFormatter.new(
          release_data,
          {
            repository_id: repo[:id],
            organization: repo[:organization]
          }
        ).format
      end
    end

    def paginate_and_write(content)
      paged_entities = content.each_slice(PER_PAGE).to_a
      paged_entities.each_with_index do |page, idx|
        record = build_record(content: page, page_index: idx + 1, total_pages: paged_entities.size,
                              total_records: content.size)
        @shared_storage_writer.write(record)
      end
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      { success: { type: 'github_release', content: content, page_index: page_index, total_pages: total_pages,
                   total_records: total_records } }
    end

    def client_params
      {
        private_pem: process_options[:private_pem],
        app_id: process_options[:app_id],
        organization: process_options[:organization]
      }
    end
  end
end
