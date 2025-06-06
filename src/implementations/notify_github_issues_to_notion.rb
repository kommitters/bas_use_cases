# frozen_string_literal: true

require 'httparty'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::NotifyGithubIssuesToNotion class serves as a bot implementation to send GitHub issues
  # data to a Notion database.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync",
  #     tag: 'FormatGithubIssues',
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync",
  #     tag: 'NotifyGithubIssues'
  #   }
  #
  #   options = {
  #     notion_database_id: 'database_id',
  #     notion_secret: 'notion_secret'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyGithubIssuesToNotion.new(options, shared_storage).execute
  #
  class NotifyGithubIssuesToNotion < Bas::Bot::Base
    NOTION_API_URL = 'https://api.notion.com/v1/pages'

    ##
    # Processes formatted GitHub issues and sends them to a Notion database.
    #
    # Retrieves GitHub issues data, validates its format, and creates corresponding pages in the specified Notion database.
    # Returns a hash indicating success with the number of created pages and their results, or an error message if processing fails.
    #
    # @return [Hash] Result of the operation, including created page count and details, or an error message.
    def process
      formatted_issues = read_response.data
      return { error: { message: 'No formatted issues data found' } } unless formatted_issues.is_a?(Array)

      results = send_issues_to_notion(formatted_issues)
      { success: { created_pages: results.count, results: results } }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    ##
    # Sends each GitHub issue to Notion as a new page and collects the results.
    #
    # Iterates over the provided issues array, creating a Notion page for each issue and recording the outcome.
    #
    # @param issues [Array<Hash>] Array of GitHub issue data to be sent to Notion
    # @return [Array<Hash>] Array of result hashes containing the issue number, HTTP status code, and response body for each page creation
    def send_issues_to_notion(issues)
      results = []

      issues.each do |issue|
        response = create_notion_page(issue)
        results << {
          issue_number: issue[:number],
          status: response.code,
          response_body: response.parsed_response
        }
      end

      results
    end

    ##
    # Creates a new page in the Notion database for the given GitHub issue.
    #
    # @param issue [Hash] The GitHub issue data to be sent to Notion.
    # @return [HTTParty::Response] The HTTP response from the Notion API.
    def create_notion_page(issue)
      body = build_notion_payload(issue)
      HTTParty.post(NOTION_API_URL, headers: notion_headers, body: body.to_json)
    end

    ##
    # Constructs the payload for creating a Notion page from GitHub issue data.
    #
    # Builds a hash with the parent database ID, page properties (excluding 'children'), and any child blocks for use in a Notion API request.
    #
    # @param issue_data [Hash] The GitHub issue data, including properties and optional 'children' blocks.
    # @return [Hash] The payload formatted for the Notion API.
    def build_notion_payload(issue_data)
      {
        parent: { database_id: process_options[:notion_database_id] },
        properties: issue_data.except('children'),
        children: issue_data['children']
      }
    end

    ##
    # Returns the HTTP headers required for authenticating and sending requests to the Notion API.
    #
    # @return [Hash] Headers including authorization, content type, and Notion API version
    def notion_headers
      {
        'Authorization' => "Bearer #{process_options[:notion_secret]}",
        'Content-Type' => 'application/json',
        'Notion-Version' => '2022-06-28'
      }
    end
  end
end
