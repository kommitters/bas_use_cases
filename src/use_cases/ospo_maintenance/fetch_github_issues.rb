# frozen_string_literal: true

require 'bas/bot/fetch_github_issues'
require 'json'

module Fetch
  # Service to fetch ptos from a notion database
  class GithubIssues
    def initialize(params)
      @params = params
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::FetchGithubIssues.new(options)

      bot.execute
    end

    private

    def connection
      {
        host: @params[:db_host],
        port: @params[:db_port],
        dbname: @params[:db_name],
        user: @params[:db_user],
        password: @params[:db_password]
      }
    end

    def read_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: @params[:tag]
      }
    end

    def process_options # rubocop:disable Metrics/MethodLength
      {
        private_pem: @params[:private_pem],
        app_id: @params[:app_id],
        repo: @params[:repo],
        filters: { state: 'all' },
        organization: @params[:organization],
        domain: @params[:domain],
        work_item_type: @params[:work_item_type],
        type_id: @params[:type_id],
        connection:,
        db_table: @params[:table_name],
        tag: 'GithubIssueRequest'
      }
    end

    def write_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: @params[:tag]
      }
    end
  end
end
