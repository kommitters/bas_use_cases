# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/github/octokit_client'
require 'time'
require_relative '../../src/utils/warehouse/github/pull_requests_formatter'
require_relative '../services/postgres/github_repository'

module Implementation
  # Implementation::FetchPullRequestsFromGithub
  #
  #  Implements a bot that fetches pull requests, their reviews, and all
  #  associated data from all repositories in a GitHub organization.
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::Database::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchPullRequestsFromGithubKommitters']
  #   }
  #
  #   write_options = {
  #     connection: Config::Database::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchPullRequestsFromGithubKommitters'
  #   }
  #
  #   github_config = Config::Github.kommiters.merge(
  #     db_connection: Config::Database::WAREHOUSE_CONNECTION
  #   )
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FetchPullRequestsFromGithub.new(github_config, shared_storage).execute
  #
  class FetchPullRequestsFromGithub < Bas::Bot::Base # rubocop:disable Metrics/ClassLength
    PER_PAGE = 100
    DEFAULT_SINCE = Time.now - (365 * 2 * 24 * 60 * 60)

    ##
    # Main execution method.
    # Finds the next eligible repository and processes it.
    #
    def process
      repo_record = find_next_repository
      return { success: { message: 'All eligible repositories are up to date.' } } unless repo_record

      stats = process_repository(repo_record)

      {
        success: { type: 'github_pull_request', content: stats[:content], repo_processed: repo_record }
      }
    end

    ##
    # Writes data to storage and updates the repository timestamp.
    #
    def write
      response = process_response
      return if response[:error] || response.dig(:success, :repo_processed).nil?

      content = response.dig(:success, :content) || []
      repo = response.dig(:success, :repo_processed)

      paginate_and_write(content) unless content.empty?

      mark_repository_as_synced(repo[:id])
    end

    private

    ##
    # Finds the next repository that needs synchronization, ensuring
    # that Issues have been synced first.
    #
    def find_next_repository
      Services::Postgres::GithubRepository.new(process_options[:db_connection]).find_next_to_sync(
        organization: process_options[:organization],
        entity_field: :last_synced_pull_requests_at,
        dependency_field: :last_synced_issues_at # Critical: Issues must exist first
      )
    end

    ##
    # Updates the synchronization timestamp in the master table.
    #
    def mark_repository_as_synced(repo_id)
      Services::Postgres::GithubRepository.new(process_options[:db_connection]).update_sync_timestamp(
        repo_id,
        :last_synced_pull_requests_at,
        Time.now
      )
    end

    def initialize_client
      Utils::Github::OctokitClient.new(client_params).execute
    end

    def process_repository(repo)
      client_response = initialize_client
      return { content: [] } if client_response[:error]

      # Reconstruct full name dynamically
      repo_full_name = "#{repo[:organization]}/#{repo[:name]}"
      cutoff_date = repo[:last_synced_pull_requests_at] || DEFAULT_SINCE

      raw_prs = fetch_updated_prs(client_response[:client], repo_full_name, cutoff_date)
      formatted_prs = normalize_response(raw_prs, repo)

      { content: formatted_prs }
    end

    ##
    # Fetches pull requests updated since the cutoff date, handling pagination
    #
    def fetch_updated_prs(client, repo_full_name, cutoff_date) # rubocop:disable Metrics/MethodLength
      page = 1

      [].tap do |collected|
        loop do
          batch = fetch_pr_page(client, repo_full_name, page)
          break if batch.empty?

          fresh_batch = select_fresh_prs(batch, cutoff_date)
          collected.concat(fresh_batch)

          break if should_stop_fetching?(batch, fresh_batch, cutoff_date, client)

          page += 1
        end
      end
    end

    def fetch_pr_page(client, repo_name, page)
      options = { state: 'all', sort: 'updated', direction: 'desc', per_page: PER_PAGE, page: page }
      client.pull_requests(repo_name, options)
    end

    def select_fresh_prs(batch, cutoff_date)
      batch.select { |pr| pr[:updated_at] > cutoff_date }
    end

    def should_stop_fetching?(full_batch, fresh_batch, cutoff_date, client)
      return true if fresh_batch.size < full_batch.size

      return true if full_batch.last[:updated_at] <= cutoff_date

      !client.last_response.rels[:next]
    end

    def normalize_response(prs, repo)
      prs.map do |pr_data|
        Utils::Warehouse::Github::PullRequestsFormatter.new(
          pr_data,
          { repository_id: repo[:id] }
        ).format
      end
    end

    def paginate_and_write(content)
      paged_entities = content.each_slice(PER_PAGE).to_a
      paged_entities.each_with_index do |page, idx|
        record = build_record(
          content: page, page_index: idx + 1,
          total_pages: paged_entities.size,
          total_records: content.size
        )
        @shared_storage_writer.write(record)
      end
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: 'github_pull_request', content: content, page_index: page_index,
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
  end
end
