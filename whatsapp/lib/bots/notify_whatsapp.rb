# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/discord/integration'

module Implementation
  ##
  # The Implementation::NotifyDiscord class serves as a bot implementation to send messages to a
  # Discord readed from a PostgresDB table.
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
  #     tag: "NotifyDiscord"
  #   }
  #
  #   options = {
  #     name: "discord bot name",
  #     webhook: "discord webhook"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyDiscord.new(options, shared_storage).execute
  #
  class NotifyWhatsapp < Bas::Bot::Base
    TOKEN = ENV.fetch('WHATSAPP_TOKEN')
    META_API_URL = 'https://graph.facebook.com/v21.0/418771694660258/messages'

    # process function to execute the Discord utility to send the PTO's notification
    #
    def process
      return { success: {} } if unprocessable_response

      website_users.each do |conversation_id|
        send_response(conversation_id, read_response.data['notification'])
      end

      { success: {} }
    end

    private

    def send_response(conversation_id, message_body)
      body = build_body(conversation_id, message_body)

      HTTParty.post(META_API_URL, headers:, body:)
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{TOKEN}"
      }
    end

    def build_body(conversation_id, message)
      {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to: "+#{conversation_id}",
        type: 'text',
        text: {
          preview_url: true,
          body: message
        }
      }.to_json
    end

    def website_users
      requests = Utils::Postgres::Request.execute(params)
      requests.first.nil? ? [] : requests.map { |user| user[:conversation_id] }
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
