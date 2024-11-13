# frozen_string_literal: true

require 'telegram/bot'
require 'bas/bot/base'
require 'bas/read/postgres'
require 'bas/utils/postgres/request'
require 'bas/write/postgres'

module Bot
  ##
  # The Bot::NotifyTelegram class serves as a bot implementation to send messages to a
  # Telegram chat read from a PostgresDB table.
  #
  class NotifyTelegram < Bot::Base
    def read
      reader = Read::Postgres.new(read_options.merge(conditions))
      reader.execute
    end

    def process
      return { success: {} } if unprocessable_response

      telegram_bot

      { success: {} }
    end

    def write
      writer = Write::Postgres.new(write_options, process_response)
      writer.execute
    end

    private

    def conditions
      {
        where: 'archived = $1 AND tag = $2 AND stage = $3 ORDER BY inserted_at ASC',
        params: [false, read_options[:tag], 'unprocessed']
      }
    end

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
