# frozen_string_literal: true
require 'logger'
require 'discordrb'

module Bots
  ##
  # Discord bot to get images from a private message with a bot and return a review
  #
  #
  class DiscordImages
    attr_reader :bot, :user_message, :connection

    def initialize(token, connection)
      token = "Bot #{token}"
      @bot = Discordrb::Bot.new(token: token)
      @connection = connection
    end

    def execute
      bot.pm do |event|
        message = event.message
        process_message(message)
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end
    end

    private

    def process_message(message)
      if message.attachments.any? && message.attachments.first.image?
        image = message.attachments
        respond("Hi, I'm processing your image...")
        response = Utils::Discord::Request.get_discord_images(message)

        if !response.nil?
          { success: response }
        else
          { error: "response is empty" }
        end
        sleep(1)
      end
    end

  end
end
