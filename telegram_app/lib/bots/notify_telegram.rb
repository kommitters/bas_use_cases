# frozen_string_literal: true

require 'telegram/bot'
require 'bas/bot/base'
require 'bas/utils/postgres/request'

module Implementation
  ##
  # The Implementation::NotifyTelegram class serves as a bot implementation to send messages to a
  # Telegram chat read from a PostgresDB table.
  #
  class NotifyTelegram < Implementation::Base
    def process
      return { success: {} } if unprocessable_response

      telegram_bot

      { success: {} }
    end

    private

    def telegram_bot
      bot = Telegram::Bot::Client.new(process_options[:token])

      website_users.each do |conversation_id|
        bot.api.send_message(chat_id: conversation_id, text: read_response.data['notification'])
      end
    end

    def website_users
      requests = Utils::Postgres::Request.execute(params)
      requests.values.flatten
    end

    def params
      {
        connection: process_options[:connection],
        query:
      }
    end

    def query
      "SELECT conversations.conversation_id
       FROM conversations
       JOIN observed_websites_conversations ON observed_websites_conversations.conversation_id = conversations.id
       JOIN observed_websites ON observed_websites.id = observed_websites_conversations.observed_website_id
       WHERE url = '#{read_response.data['url']}'"
    end
  end
end
