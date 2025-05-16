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
      # Get the Notion database ID and secret from the process options
      database_id = @process_options[:notion_database_id]
      secret = @process_options[:notion_secret]

      # Get data from the read response with the information to update Notion DB
      data = @read_response.data

      unless data.is_a?(Hash)
        puts "Expected data to be a Hash"
        return { error: "Invalid data format" }
      end

      # Get month from the data
      target_month = data["month"]
      unless target_month.is_a?(String) && !target_month.strip.empty?
        puts "'month' is missing or invalid"
        return { error: "'month' field missing or invalid" }
      end

      # Search for the page in Notion database
      pages = Utils::Notion::Request.execute({
        endpoint: "databases/#{database_id}/query",
        secret: secret,
        method: "post",
        body: {}
      })

      results = pages["results"]
      if results.nil?
        puts "No results found in Notion response"
        return { error: "No results found in Notion response" }
      end

      page = results.find do |p|
        title = p.dig("properties", "Month", "title")
        title && title[0] && title[0]["plain_text"] == target_month
      end

      unless page
        puts "No Notion page found for month '#{target_month}'"
        return { error: "Notion page for '#{target_month}' not found" }
      end

      # Build the body for the Notion update request
      body = {
        properties: {}
      }

      # Map keys from Notion database
      notion_fields = {
        "closed_issues" => "Closed Tickets",
        "opened_issues" => "Opened Issues",
        "previous_open_issues" => "Previous open issues"
      }

      # Iterate over the keys and map them to Notion properties
      notion_fields.each do |key, notion_property_name|
        issue_data = data[key]

        unless issue_data.is_a?(Hash)
          puts "Missing values for '#{key}'"
          next
        end

        value = issue_data["value"]
        unless value.is_a?(Numeric)
          puts "⚠️ Invalid value for '#{key}', using 0"
          value = 0
        end

        body[:properties][notion_property_name] = { number: value }
      end

      if body[:properties].empty?
        puts "No valid issue data found to update"
        return { error: "No valid issue data found to update" }
      end

      puts "Updating page with: #{body.inspect}"

      # Update the Notion page with the new data
      response = Utils::Notion::UpdateDatabasePage.new({
        page_id: page["id"],
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
