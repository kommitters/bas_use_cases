# frozen_string_literal: true

require 'httparty'
require 'json'

module Utils
  module GoogleChat
    ##
    # This module is a Google chat utility to send messages to a google chat space
    #
    class SendMessageWebhookWorkspace
      include HTTParty

      def initialize(webhook_url)
        @webhook_url = webhook_url
      end

      def send_message(text)
        options = {
          headers: { 'Content-Type' => 'application/json' },
          body: { text: text }.to_json
        }

        response = self.class.post(@webhook_url, options)
        { code: response.code.to_i, body: response.body }
      end
    end
  end
end
