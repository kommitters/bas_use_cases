# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'httparty'
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
        token = ENV.fetch('WHATSAPP_TOKEN')
        case body
        when '/add'
          puts 'Response: Waiting for URL'
          puts response(token, conversation_id, 'Please send the URL of the website you want to monitor')
          {
            success: {
              status: 200
          }}
        when '/remove'
          websites = list_websites(options, conversation_id)
          puts response(token, conversation_id, 'Please send the number of the website you want to remove')
          {
            success: {
              status: 200
          }}
        when '/list'
          puts 'Received /list command'
          request = list_websites(options, conversation_id)
          puts "Your websites are: #{request}"
          {
            success: {
              status: 200
          }}
        else
          unprocessable_response(body, conversation_id, options)
        end
      end

      private

      def response(token, conversation_id, message_body)
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{token}"
        }
      
        response = HTTParty.post(
          'https://graph.facebook.com/v17.0/393901540484202/messages',
          headers: headers,
          body: {
            messaging_product: "whatsapp",
            recipient_type: "individual",
            to: "+#{conversation_id}",
            type: "text",
            text: {
              preview_url: true,
              body: message_body
            }
          }.to_json
        )
      
        response.body  # Retorna la respuesta completa
      end
      def unprocessable_response(body, conversation_id, options)
        # Check if the body is a string that can be converted to an integer
        if body.to_i.to_s == body
          delete_website(body, conversation_id, options)
        # Check if the body is a valid URL (simple check for a URL pattern)
        elsif body.match?(%r{\Ahttp(s)?://\S+\.\S+}) ? body : "https://#{body}"
          add_url(body, options, conversation_id)
        else
          {
            error: {
              status: 422
          }}
        end
        {
          success: {
            status: 200
        }}
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
        token = ENV.fetch('WHATSAPP_TOKEN')
        config = {
          connection: options,
          conversation_id: conversation_id
        }
        response = Services::ListWebsites.new(config).execute
        message_body = "Your websites are:\n#{response.each_with_index.map { |w, index| "#{index + 1}. #{w[:url]}" }.join("\n")}"
        puts message_body
        puts response(token, conversation_id, message_body)
        {
          success: {
            status: 200
        }}
      end

      def delete_website(index, conversation_id, options)
        config_list = {
          connection: options,
          conversation_id: conversation_id
        }
        result = Services::ListWebsites.new(config_list).execute
        website = result[index.to_i - 1][:url]
        puts "Deleting website: #{website}"
        config = { connection: options, website: website, conversation_id: conversation_id }
        Services::RemoveWebsite.new(config).execute
        200
      end
    end
  end
end
