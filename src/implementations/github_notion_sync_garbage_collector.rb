# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/postgres/request'

module Implementation
  ##
  # The Implementation::GithubNotionSyncGarbageCollector class serves as a bot implementation to archive
  # github_notion_issues_sync records from the PostgresDB database table.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync"
  #   }
  #
  #   options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::GithubNotionSyncGarbageCollector.new(options, shared_storage).execute
  #
  class GithubNotionSyncGarbageCollector < Bas::Bot::Base
    SUCCESS_STATUS = 'PGRES_COMMAND_OK'

    def process
      Utils::Postgres::Request.execute(params)
      { success: { archived: true } }
    end

    private

    def params
      {
        connection: process_options[:connection],
        query: query
      }
    end

    def query
      "UPDATE #{process_options[:db_table]} SET archived=true WHERE archived=false"
    end
  end
end