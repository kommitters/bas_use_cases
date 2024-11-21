# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'httparty'

require_relative '../../../src/services/add_website'
require_relative '../../../src/services/list_websites'
require_relative '../../../src/services/remove_website'

module Bas
  module Bot
    class CommandProcessor < Bas::Bot::Base
      TOKEN = ENV.fetch('WHATSAPP_TOKEN')

      def process
        conversation_id = read_response.data['conversation_id']
        body = read_response.data['message']
        options = process_options

        begin
          case body
          when '/add' then add
          when '/remove' then remove
          when '/list' then list
          else unprocessable_response
          end
        rescue StandardError
          { error: { status: 422 } }
        end

        { success: { status: 200 } }
      end

      private

      def response(conversation_id, message_body)
        response = HTTParty.post(
          'https://graph.facebook.com/v17.0/393901540484202/messages',
          headers: get_headers,
          body: {
            messaging_product: 'whatsapp',
            recipient_type: 'individual',
            to: "+#{conversation_id}",
            type: 'text',
            text: {
              preview_url: true,
              body: message_body
            }
          }.to_json
        )

        response.body # Retorna la respuesta completa
      end

      def add
        conversation_id = read_response.data['conversation_id']
        response(conversation_id, 'Please send the URL of the website you want to monitor')
      end

      def remove
        conversation_id = read_response.data['conversation_id']
        options = process_options

        response(conversation_id, 'Please send the number of the website you want to remove')
      end

      def list
        conversation_id = read_response.data['conversation_id']
        options = process_options

        response = list_websites(options, conversation_id)

        message_body = "Your websites are:\n#{response.each_with_index.map do |w, index|
          "#{index + 1}. #{w[:url]}"
        end.join("\n")}"

        response(conversation_id, message_body)
      end

      def unprocessable_response
        conversation_id = read_response.data['conversation_id']
        body = read_response.data['message']
        options = process_options

        # Check if the body is a string that can be converted to an integer
        if body.to_i.to_s == body
          delete_website(body, conversation_id, options)
        # Check if the body is a valid URL (simple check for a URL pattern)
        elsif body.match?(%r{\Ahttp(s)?://\S+\.\S+}) ? body : "https://#{body}"
          add_url(body, options, conversation_id)
        end
      end

      def get_headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{TOKEN}"
        }
      end

      def valid_url?(message)
        message.match?(%r{\Ahttp(s)?://\S+\.\S+}) ? message : "https://#{message}"
      end

      def add_url(url, options, conversation_id)
        config = {
          connection: options,
          conversation_id: conversation_id,
          url: url
        }
        Services::AddWebsite.new(config).execute
      end

      def list_websites(options, conversation_id)
        config = {
          connection: options,
          conversation_id: conversation_id
        }

        Services::ListWebsites.new(config).execute
      end

      def delete_website(index, conversation_id, options)
        config_list = {
          connection: options,
          conversation_id: conversation_id
        }

        result = Services::ListWebsites.new(config_list).execute
        website = result[index.to_i - 1][:url]
        config = { connection: options, website: website, conversation_id: conversation_id }

        Services::RemoveWebsite.new(config).execute
      end
    end
  end
end
