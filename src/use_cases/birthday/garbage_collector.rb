# frozen_string_literal: true

require 'bas/bot/garbage_collector'
require 'json'

module GarbageCollector
  # Service to archive old records
  class Birthday
    def initialize(params)
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { process_options:, write_options: }

      bot = Bot::GarbageCollector.new(options)

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
        connection:,
        db_table: @table_name
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'GarbageCollector'
      }
    end
  end
end
