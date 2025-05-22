# frozen_string_literal: true

require 'bas/bot/base'
require 'discordrb'

module Implementation
  ##
  # The Implementation::NotifyWorklogInDiscordDm class sends a daily summary of worklogs
  # as a DM to a specified Discord user.
  #
  class NotifyWorklogInDiscordDm < Bas::Bot::Base
    # Process function to send a DM with the daily worklogs summary
    def process
      validate_options
      return { success: {} } if unprocessable_response

      send_discord_dm
    rescue StandardError => e
      log_error(e)
      { error: { message: e.message } }
    end

    private

    def validate_options
      raise 'Discord token is missing' if process_options[:token].nil? || process_options[:token].empty?
      return unless process_options[:discord_user_id].nil? || process_options[:discord_user_id].empty?

      raise 'Discord user ID is missing'
    end

    def send_discord_dm
      bot = Discordrb::Bot.new(token: process_options[:token])
      user = bot.user(process_options[:discord_user_id])
      notification = read_response.data['notification']

      user.dm(notification)
      { success: { message: 'DM sent successfully' } }
    end

    def log_error(error)
      Logger.new($stdout).info("Error sending DM: #{error.message}")
    end
  end
end
