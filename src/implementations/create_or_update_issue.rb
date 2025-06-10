# frozen_string_literal: true

require 'json'
require 'md_to_notion'
require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'bas/utils/notion/types'
require 'bas/utils/notion/delete_page_blocks'
require 'bas/utils/notion/fetch_database_record'
require 'bas/utils/notion/update_db_page'
require_relative '../utils/create_notion_db_entry'

module Implementation
  ##
  # The Implementation::UpdateWorkItem class serves as a bot implementation to update "work items" on a
  # notion database using information of a GitHub issue.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: "UpdateWorkItemRequest"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: "UpdateWorkItem"
  #   }
  #
  #   options = {
  #     users_database_id: "notion_database_id",
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateWorkItem.new(options, shared_storage).execute
  #
  class CreateOrUpdateIssue < Bas::Bot::Base
    NOTION_PROPERTY = 'Github issue id'

    # process function to execute the Notion utility to delete work items on a notion
    # database if they exists
    def process
      return { error: { message: 'Empty issue data received' } } if unprocessable_response

      @issue_id = read_response.data['issue_id'].to_s
      @issue_number = read_response.data['issue_number'].to_s
      result = process_wi

      if %i[created updated].include?(result)
        { success: { action: result, issue_id: read_response.data['issue_id'] } }
      else
        { error: { message: "Item was not updated nor created. Reason: #{result}", issue_id: @issue_id } }
      end
    end

    private

    def process_wi
      response = fetch_record

      if response.is_a?(Array) && !response.empty?
        page_id = response.first['id']
        update_response = update_record(page_id) if page_id.is_a?(String)
        return "cannot_update_error_#{update_response.code}".to_sym if update_response.code != 200

        :updated
      else
        create_response = Utils::Notion::CreateNotionDbEntry.new(
          process_options[:secret], process_options[:database_id], read_response.data['notion_object']
        ).execute
        return "cannot_create_error_#{update_response.code}".to_sym if create_response.code != 200

        :created
      end
    end

    def fetch_record
      options = {
        database_id: process_options[:database_id],
        secret: process_options[:secret],
        body: {
          filter: { property: NOTION_PROPERTY, rich_text: { equals: @issue_number } }
        }
      }

      Utils::Notion::FetchDatabaseRecord.new(options).execute
    end

    def update_record(page_id)
      options = {
        page_id: page_id,
        secret: process_options[:secret],
        body: { properties: read_response.data['notion_object'].except('children', NOTION_PROPERTY) }
      }

      Utils::Notion::UpdateDatabasePage.new(options).execute
    end
  end
end
