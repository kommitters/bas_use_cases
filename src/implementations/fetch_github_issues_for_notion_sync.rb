# frozen_string_literal: true

require 'httparty'
require 'date'
require 'bas/bot/base'
require 'octokit'

module Implementation
  ##
  # The Implementation::FetchGithubIssuesForNotionSync class serves as a bot implementation to fetch issues from
  # a specific GitHub repository and process them for Notion synchronization.
  #
  # <br>
  # <b>Example</b>
  #
  #  write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'github_notion_issues_sync',
  #   tag: 'FetchGithubIssues'
  #  }
  #
  #   options = {
  #     repo_identifier: 'owner/repo',
  #     github_api_token: 'github_token'
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  # Implementation::FetchGithubIssuesForNotionSync.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchGithubIssuesForNotionSync < Bas::Bot::Base
    ##
    # Fetches issues from a GitHub repository and prepares them for Notion synchronization.
    #
    # Uses the provided repository identifier and GitHub API token to retrieve issues via the Octokit client.
    # Returns a hash containing either the extracted issue data or an error message if fetching fails.
    #
    # @return [Hash] A hash with either a `:success` key containing an array of issue data, or an `:error` key with a message.
    def process
      issues = octokit_client.issues(process_options[:repo_identifier])
      return { error: { message: 'Failed to fetch issues from GitHub' } } if issues.nil?

      { success: extract_issue_data(issues) }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    ##
    # Initializes and returns an Octokit client using the provided GitHub API token.
    #
    # @return [Octokit::Client] Configured client for GitHub API access
    def octokit_client
      Octokit::Client.new(access_token: process_options[:github_api_token])
    end

    # @return [Array<Hash>] Array of hashes containing only the :html_url, :number, :title, :labels, and :body fields for each issue
    def extract_issue_data(issues)
      issues.map do |issue|
        issue.to_h.slice(:html_url, :number, :title, :labels, :body)
      end
    end
  end
end
