# frozen_string_literal: true
require 'logger'
require 'discordrb'

require 'bas/utils/discord/request'

module Bots
  ##
  # Discord bot to get images from a private message with a bot and return a review
  #
  #
  class DiscordImages
    attr_reader :bot, :user_message, :connection

    def initialize(token, client_id, connection)
      token = "Bot #{token}"
      @bot = Discordrb::Bot.new(token: token, client_id: client_id)
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
        response = Utils::Discord::Request.get_discord_images(message)

        if !response.nil?
          { success: response }
        else
          { error: "response is empty" }
        end
      else
        event.respond("Please, send me an image to analyze")
      end
    end

  end
end
