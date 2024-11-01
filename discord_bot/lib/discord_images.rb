# frozen_string_literal: true

require 'discordrb'
require 'bas/utils/discord/request'
require 'bas/write/postgres'

module Bots
  ##
  # Discord bot to get images from a private message with a bot and return a review
  #
  class DiscordImages
    attr_reader :commands

    def initialize(db_connection)
      @db_connection = db_connection
      @commands = {}
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

    def custom_handler(event, message, event_entity, bot_instance)
      @event = event
      @bot_instance = bot_instance
      @message = message
      @event_entity = event_entity
      process_message(event.message, event)
    end

    def get_images(message)
      response = Utils::Discord::Request.get_discord_images(message)
      save_in_shared_storage(response) if response
    end

    def save_in_shared_storage(response)
      process_options = {
        connection: @db_connection,
        db_table: 'review_images',
        tag: 'ReviewMediaRequest'
      }

      write_data = { success: response }
      Write::Postgres.new(process_options, write_data).execute
    end
  end
end
