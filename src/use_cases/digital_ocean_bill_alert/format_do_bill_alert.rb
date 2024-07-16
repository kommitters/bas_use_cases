# frozen_string_literal: true

require 'bas/bot/format_do_bill_alert'
require 'json'

module Format
  # Service to format digital ocean billing alerts
  class DoBillAlert
    def initialize(params)
      @threshold = params[:threshold]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::FormatDoBillAlert.new(options)

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
        tag: 'FetchBillingFromDigitalOcean'
      }
    end

    def process_options
      { threshold: @threshold.to_f }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FormatDoBillAlert'
      }
    end
  end
end
