# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::FetchRepositoriesFromNotion class serves as a bot implementation to read OSS project
  # repositories from a notion database and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "repos_score",
  #     tag: "FetchRepositoriesFromNotion"
  #   }
  #
  #   options = {
  #     database_id: "notion_database_id",
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::FetchRepositoriesFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchRepositoriesFromNotion < Bas::Bot::Base
    # Process function to execute the Notion utility to fetch OSS projects info from a notion database
    #
    def process
      response = Utils::Notion::Request.execute(params)
      
      if response.code == 200
        repos_list = normalize_response(response.parsed_response['results'])
        { success: { repos: repos_list } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
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
          and: [{ property: 'OSSF SCORECARD', checkbox: { equals: true } }]
        }
      }
    end

    def normalize_response(results)
      return [] if results.nil?

      results.map do |value|
        repo_fields = value['properties']

        {
          'name' => repo_fields['Name']['title'].map { |t| t['plain_text'] }.join,
          'repo' => repo_fields['Repo']['url'],
          'page_id' => value['id']
        }
      end
    end
  end
end
