# frozen_string_literal: true

require 'bas/bot/fetch_domains_wip_counts_from_notion'
require 'json'

module Fetch
  # Service to fetch WIP counts from a notion database
  class DomainsWipCountFromNotion
    def initialize(params)
      @notion_database_id = params[:notion_database_id]
      @notion_secret = params[:notion_secret]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { process_options:, write_options: }

      bot = Bot::FetchDomainsWipCountsFromNotion.new(options)

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

    def process_options
      {
        database_id: @notion_database_id,
        secret: @notion_secret
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FetchDomainsWipCountsFromNotion'
      }
    end
  end
end
