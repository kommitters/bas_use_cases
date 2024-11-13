# frozen_string_literal: true

require 'bas/bot/compare_wip_limit_count'
require 'json'

module Compare
  # Service to compare count WIP's and the domains limits
  class WipLimitCount
    def initialize(params)
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, write_options: }

      bot = Bot::CompareWipLimitCount.new(options)

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
        db_table: @table_name,
        tag: 'FetchDomainsWipLimitFromNotion'
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'CompareWipLimitCount'
      }
    end
  end
end
