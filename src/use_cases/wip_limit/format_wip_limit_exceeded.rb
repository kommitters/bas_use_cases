# frozen_string_literal: true

require 'bas/bot/format_wip_limit_exceeded'
require 'json'

module Format
  # Service to format exceeded WIP limits
  class WipLimitExceeded
    def initialize(params)
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::FormatWipLimitExceeded.new(options)

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
        tag: 'CompareWipLimitCount'
      }
    end

    def process_options
      {
        template: ':warning: The <domain> WIP limit was exceeded by <exceeded>'
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FormatWipLimitExceeded'
      }
    end
  end
end
