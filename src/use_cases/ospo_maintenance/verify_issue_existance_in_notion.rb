# frozen_string_literal: true

require 'bas/bot/verify_issue_existance_in_notion'
require 'json'

module Verify
  # Service to fetch ptos from a notion database
  class IssueExistanceInNotion
    def initialize(params)
      @params = params
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::VerifyIssueExistanceInNotion.new(options)

      bot.execute
    end

    private

    def connection
      {
        host: @db_host,
        port: @db_port,
        dbname: @db_name,
        user: @db_user,
        password: @db_password
      }
    end

    def read_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: 'GithubIssueRequest'
      }
    end

    def process_options
      {
        database_id: @params[:database_id],
        secret: @params[:secret]
      }
    end

    def write_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: 'VerifyIssueExistanceInNotio'
      }
    end
  end
end
