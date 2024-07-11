# frozen_string_literal: true

require 'bas/bot/notify_discord'
require 'json'

module Notify
  # Service to format digital ocean billing alerts
  class DoBollAlertDiscord
    def initialize(params)
      @discord_webhook = params[:discord_webhook]
      @discord_bot_name = params[:discord_bot_name]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::NotifyDiscord.new(options)

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
        tag: 'FormatDoBillAlert',
        avoid_process: true
      }
    end

    def process_options
      {
        name: @discord_bot_name,
        webhook: @discord_webhook
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'NotifyDiscord'
      }
    end
  end
end
