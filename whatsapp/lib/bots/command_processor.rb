# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'httparty'

require_relative '../../services/add_website'
require_relative '../../services/list_websites'
require_relative '../../services/remove_website'

module Implementation
  ##
  # The Implementation::CommandProcessor module is a bot implemented with the BAS gem
  # to process messages or command send by a user through a chat bot.
  #
  class CommandProcessor < Bas::Bot::Base
    TOKEN = ENV.fetch('WHATSAPP_TOKEN')
    META_API_URL = 'https://graph.facebook.com/v21.0/418771694660258/messages'

    def process
      { success: { result: process_message } }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def process_message
      case read_response.data['message']
      when '/add' then add
      when '/remove' then remove
      when '/list' then list
      else unprocessable_response
      end
    end

    def add
      send_response('Please send the URL of the website you want to monitor')
    end

    def remove
      send_response('Please send the number of the website you want to remove')
    end

    def list
      websites = list_websites.each_with_index.map { |website, index| "- #{index + 1}. #{website[:url]}" }.join("\n")

      message_body = "Your websites are:\n#{websites}"

      send_response(message_body)
    end

    def unprocessable_response
      user_message = read_response.data['message']

      if user_message.match?('\A\d+\z')
        delete_website(user_message)
      else
        url = user_message.match?(%r{\Ahttp(s)?://\S+\.\S+}) ? user_message : "https://#{user_message}"

        add_website(url)
      end
    end

    def send_response(message_body)
      body = build_body(message_body)

      HTTParty.post(META_API_URL, headers:, body:)
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{TOKEN}"
      }
    end

    def build_body(message)
      {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to: "+#{read_response.data['conversation_id']}",
        type: 'text',
        text: {
          preview_url: true,
          body: message
        }
      }.to_json
    end

    def add_website(url)
      config = {
        connection: process_options,
        conversation_id: read_response.data['conversation_id'],
        url: url
      }

      Services::AddWebsite.new(config).execute
    end

    def list_websites
      config = {
        connection: process_options,
        conversation_id: read_response.data['conversation_id']
      }

      Services::ListWebsites.new(config).execute
    end

    def delete_website(index)
      website = list_websites[index.to_i - 1][:url]

      config = {
        connection: process_options,
        website: website,
        conversation_id: read_response.data['conversation_id']
      }

      Services::RemoveWebsite.new(config).execute
    end
  end
end
