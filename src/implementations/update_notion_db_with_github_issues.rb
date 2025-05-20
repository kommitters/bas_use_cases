# frozen_string_literal: true

require "date"
require "bas/bot/base"
require "bas/utils/notion/request"
require "bas/utils/notion/update_db_page"

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
  #     where: "tag=$1 ORDER BY inserted_at DESC LIMIT 1",
  #     params: ['GithubIssueRequest']
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
      database_id = process_options[:notion_database_id]
      secret = process_options[:notion_secret]
      data = read_response.data
      target_month = data["month"]

      page = find_notion_page(database_id, secret, target_month)
      return { error: "Notion page for '#{target_month}' not found" } unless page

      body = build_update_body(data)

      update_page(page["id"], secret, body, target_month)
    end

    private

    def find_notion_page(database_id, secret, target_month)
      pages = Utils::Notion::Request.execute({
        endpoint: "databases/#{database_id}/query",
        secret: secret,
        method: "post",
        body: {}
      })

      results = pages["results"]
      return nil unless results

      results.find do |p|
        title = p.dig("properties", "Month", "title")
        title&.first&.dig("plain_text") == target_month
      end
    end

    def build_update_body(data)
      body = { properties: {} }
      notion_fields = {
        "closed_issues" => "Closed Tickets",
        "opened_issues" => "Opened Issues",
        "previous_open_issues" => "Previous open issues"
      }

      notion_fields.each do |key, notion_property_name|
        issue_data = data[key]

        unless issue_data.is_a?(Hash)
          puts "Missing values for '#{key}'"
          next
        end

        value = issue_data["value"]
        unless value.is_a?(Numeric)
          puts "Invalid value for '#{key}', using 0"
          value = 0
        end

        body[:properties][notion_property_name] = { number: value }
      end

      body
    end

    def update_page(page_id, secret, body, target_month)
      puts "Updating page with: #{body.inspect}"

      response = Utils::Notion::UpdateDatabasePage.new({
        page_id: page_id,
        secret: secret,
        body: body
      }).execute

      if response.code == 200
        puts "Page updated successfully for month '#{target_month}'"
        { success: true }
      else
        puts "Error updating Notion: #{response.body}"
        { error: "Failed to update Notion page", status: response.code }
      end
    end
  end
end
