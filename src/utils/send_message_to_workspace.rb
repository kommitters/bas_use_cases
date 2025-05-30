# frozen_string_literal: true

require 'google/apis/chat_v1'
require 'googleauth'
require 'google/apis/core/logging'

module Utils
  module GoogleChat
    ##
    # This module is a Google chat utility to send messages to a google chat space
    # using google chat API
    #
    class SendMessageToWorkspace
    Chat = Google::Apis::ChatV1

      def initialize(space_id:, credentials_path: 'src/utils/credentials.json', debug: false)
        @space = "spaces/#{space_id}"
        @credentials_path = File.expand_path(credentials_path)
        @scopes = ['https://www.googleapis.com/auth/chat.bot']

        Google::Apis.logger.level = Logger::DEBUG if debug

        setup_authentication
        setup_chat_service
      end

      def send_text_message(text)

        message = Chat::Message.new(text: text)

        begin
          result = @chat_service.create_space_message(@space, message)
        rescue => e
          puts "❌ Error sending message: #{e.message}"
        raise
        end
      end

      private

      def setup_authentication
        @authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(@credentials_path),
          scope: @scopes
        )
        @authorization.fetch_access_token!
      end

      def setup_chat_service
        @chat_service = Chat::HangoutsChatService.new
        @chat_service.authorization = @authorization
       end
    end
  end
end