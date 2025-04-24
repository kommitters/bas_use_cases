# frozen_string_literal: true

require 'bas/bot/base'
require 'discordrb'

module Implementation
  ##
  # The Implementation::NotifyDiscordDm class serves as a bot implementation to send DM messages to a
  # Discord reader from a PostgresDB table.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "FormatBirthdays"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "NotifyDiscordDm"
  #   }
  #
  #   options = {
  #     name: "discord bot name",
  #     webhook: "discord webhook"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyDiscordDm.new(options, shared_storage).execute
  #
  class NotifyDiscordDm < Bas::Bot::Base
    # process function to execute the Discord utility to send the PTO's notification
    #
    def process
      return { success: {} } if unprocessable_response

      bot = Discordrb::Bot.new token: process_options[:token]
      user = bot.user(read_response.data['dm_id'])

      user.dm(read_response.data['notification'])

      { success: {} }
    end
  end
end
