# frozen_string_literal: true

require 'logger'
require 'discordrb'

require 'bas/utils/discord/request'
require 'bas/write/postgres'

module Bots
  ##
  # Discord bot to get images from a private message with a bot and return a review
  #
  #
  class DiscordImages
    attr_reader :bot, :user_message, :connection

    def initialize(token, client_id, connection)
      token = "Bot #{token}"
      @bot = Discordrb::Bot.new(token:, client_id:)
      @connection = connection
    end

    def execute
      bot.pm do |event|
        message = event.message
        process_message(message, event)
      end
    end

    private

    def process_message(message, event)
      if message.attachments.any?
        event.respond("Hi, I'm processing your image...")
        get_images(message)
      else
        event.respond('Please, send me an image to analyze')
      end
    end

    def get_images(message)
      response = Utils::Discord::Request.get_discord_images(message)

      if !response.nil?
        save_in_shared_storage(response)
      else
        { error: 'response is empty' }
      end
    end

    def save_in_shared_storage(response)
      process_options = {
        connection:,
        db_table: 'review_images',
        tag: 'ReviewMediaRequest'
      }

      write_data = { success: response }
      Write::Postgres.new(process_options, write_data).execute
    end
  end
end
