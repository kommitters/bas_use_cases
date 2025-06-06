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

    def process
      formatted_issues = read_response.data
      return { error: { message: 'No formatted issues data found' } } unless formatted_issues.is_a?(Array)

      results = send_issues_to_notion(formatted_issues)
      { success: { created_pages: results.count, results: results } }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

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

    def create_notion_page(issue)
      body = build_notion_payload(issue)
      HTTParty.post(NOTION_API_URL, headers: notion_headers, body: body.to_json)
    end

    def build_notion_payload(issue_data)
      {
        parent: { database_id: process_options[:notion_database_id] },
        properties: issue_data.except('children'),
        children: issue_data['children']
      }
    end

    def notion_headers
      {
        'Authorization' => "Bearer #{process_options[:notion_secret]}",
        'Content-Type' => 'application/json',
        'Notion-Version' => '2022-06-28'
      }
    end
  end
end
