# frozen_string_literal: true

require 'bas/bot/write_media_review_in_discord'
require 'json'

module Write
  # Service to fetch images from a private message with a Discord bot
  class ImageReviewInDiscord
    def initialize(params)
      @discord_bot_token = params[:discord_bot_token]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::WriteMediaReviewInDiscord.new(options)

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
        tag: 'ReviewImage'
      }
    end

    def process_options
      {
        secret_token: @discord_bot_token
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'WriteImageReviewInDiscord'
      }
    end
  end
end
