# frozen_string_literal: true

require 'bas/bot/notify_discord'
require 'json'

module Fetch
  # Service to fetch images from Discord thread
  class ImagesFromDiscord
    def initialize(params)
      @discord_bot_token = params[:discord_bot_token]
      @discord_channel_id = params[:discord_channel_id]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::FetchImagesFromDiscord.new(options)

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
        tag: 'FetchImagesFromDiscord'
      }
    end

    def process_options
      {
        secret_token: @discord_bot_token
        discord_channel: @discord_channel_id
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
