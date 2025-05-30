# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'bas/utils/notion/update_db_state'

module Implementation
  ##
  # The Implementation::VerifyIssueExistanceInNotion class serves as a bot implementation to verify if a
  # GitHub issue was already created on a notion database base on a column with the issue id.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: "GithubIssueRequest"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "github_issues",
  #     tag: "VerifyIssueExistanceInNotion"
  #   }
  #
  #   options = {
  #     database_id: "notion_database_id",
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::VerifyIssueExistanceInNotion.new(options, shared_storage).execute
  #
  class VerifyIssueExistanceInNotion < Bas::Bot::Base
    NOT_FOUND = 'not found'
    NOTION_PROPERTY = 'Github Issue Id'

    # process function to execute the Notion utility to verify GitHub issues existance
    # on a notion database
    #
    def process
      return { success: { issue: nil } } if unprocessable_response

      response = Utils::Notion::Request.execute(params)

      if response.code == 200
        result = response.parsed_response['results'].first

        { success: read_response.data.merge({ notion_wi: notion_wi_id(result) }) }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    # write function to execute the PostgresDB write component
    #
    def write
      @shared_storage_writer.write_options = @shared_storage_writer.write_options.merge({ tag: })

      @shared_storage_writer.write(process_response)
    end

    private

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
    end

    def body
      {
        filter: {
          property: NOTION_PROPERTY,
          rich_text: { equals: read_response.data['issue']['id'].to_s }
        }
      }
    end

    def notion_wi_id(result)
      return NOT_FOUND if result.nil?

      result['id']
    end

    def tag
      issue = process_response[:success]

      return @shared_storage_writer.write_options[:tag] if issue.nil? || issue[:notion_wi].nil?

      issue[:notion_wi].eql?(NOT_FOUND) ? 'CreateWorkItemRequest' : 'UpdateWorkItemRequest'
    end
  end
end
