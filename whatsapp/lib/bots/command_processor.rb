# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative '../../../telegram_app/lib/services/add_website'
require_relative '../../../telegram_app/lib/services/list_websites'
require_relative '../../../telegram_app/lib/services/remove_website'
module Bas
  module Bot
    class CommandProcessor < Bas::Bot::Base
      def process
        conversation_id = read_response.data['conversation_id']
        body = read_response.data['message']
        options = process_options

        case body
        when '/add'
          puts 'Response: Waiting for URL'
          200
        when '/remove'
          puts 'Received /remove command'
          200
        when '/list'
          puts 'Received /list command'
          list_websites(options, conversation_id)
          200
        else
          puts 'Response: No valid command received'
        end
        if valid_url?(body)
          puts 'Valid URL detected'
          add_url(body, options, conversation_id)
        else
          puts 'Response: Invalid URL'
        end
      end

      private

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
        Services::ListWebsites.new(config_list).execute
        website = result[index.to_i - 1][:url]
        puts "Deleting website: #{website}"
        config = { connection: options, website: website, conversation_id: conversation_id }
        Services::RemoveWebsite.new(config).execute
      end
    end
  end
end
