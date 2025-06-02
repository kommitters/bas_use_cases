# frozen_string_literal: true

require 'date'
require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'bas/utils/notion/update_db_page'

module Implementation
  ##
  # The Implementation::UpdateNotionDBWithGithubIssues class serves as a bot implementation to update
  # a Notion database with GitHub issues data.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_issues",
  #     tag: 'GithubIssueRequest',
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_issues",
  #     tag: 'GithubIssueRequest'
  #   }
  #
  #   options = {
  #     notion_database_id: Config.notion_database_id,
  #     notion_secret: Config.notion_secret,
  #     tag: 'GithubIssueRequest'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateNotionDBWithGithubIssues.new(options, shared_storage).execute
  #
  class UpdateNotionDBWithGithubIssues < Bas::Bot::Base
    def process
      page = find_notion_page

      body = build_update_body
      update_page(page['id'], body)
    end

    private

    def find_notion_page
      pages = query_notion_database
      results = pages['results']
      return nil unless results

      month_abbr = parse_month

      results.find { |p| page_matches_month?(p, month_abbr) }
    end

    def parse_month
      month = read_response.data['month']
      Date.parse("1 #{month}").strftime('%b')
    end

    def query_notion_database
      Utils::Notion::Request.execute(
        {
          endpoint: "databases/#{process_options[:notion_database_id]}/query",
          secret: process_options[:notion_secret],
          method: 'post',
          body: {}
        }
      )
    end

    def page_matches_month?(page, target_month)
      title = page.dig('properties', 'Month', 'title')
      title&.first&.dig('plain_text') == target_month
    end

    def build_update_body
      body = { properties: {} }
      fields_map.each do |key, notion_property_name|
        value = normalize_value(read_response.data[key], key)
        body[:properties][notion_property_name] = { number: value }
      end
      body
    end

    def fields_map
      {
        'closed_issues' => 'Closed Tickets',
        'opened_issues' => 'Opened Issues',
        'previous_open_issues' => 'Previous open issues'
      }
    end

    def normalize_value(issue_data, key)
      unless issue_data.is_a?(Hash)
        puts "Missing values for '#{key}'"
        return 0
      end

      value = issue_data['value']
      return value if value.is_a?(Numeric)

      puts "Invalid value for '#{key}', using 0"
      0
    end

    def update_page(page_id, body)
      puts "Updating page with: #{body.inspect}"
      response = Utils::Notion::UpdateDatabasePage.new(
        {
          page_id: page_id,
          secret: process_options[:notion_secret],
          body: body
        }
      ).execute

      handle_response(response)
    end

    def handle_response(response)
      if response.code == 200
        puts "Page updated successfully for month '#{read_response.data['month']}'"
        { success: true }
      else
        puts "Error updating Notion: #{response.body}"
        { error: 'Failed to update Notion page', status: response.code }
      end
    end
  end
end
