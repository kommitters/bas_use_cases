# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../utils/send_message_webhook_workspace'

module Implementation
  ##
  # The Implementation::NotifyWorkspace class serves as a bot implementation to send messages to a
  # Google Chat workspace read from a PostgresDB table.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "FormatBirthdaysWorkspace"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "NotifyWorkspace"
  #   }
  #
  #   options = {
  #     webhook: "Google chat space webhook"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyWorkspace.new(options, shared_storage).execute
  #
  class NotifyWorkspace < Bas::Bot::Base
    # process function to execute the Google Chat utility to send the notification
    #
    def process
      return { success: {} } if unprocessable_response

      notification_data = read_response.data['notification']
      webhook_url = extract_webhook_url

      return { success: {} } unless webhook_url

      sender = Utils::GoogleChat::SendMessageWebhookWorkspace.new(webhook_url)
      response = sender.send_message(notification_data)

      if response[:code] == 200
        { success: {} }
      else
        { error: { message: response[:body], status_code: response[:code] } }
      end
    end

    private

    def extract_webhook_url
      stored_webhook = read_response.data['webhook']
      stored_webhook = stored_webhook.strip if stored_webhook.respond_to?(:strip)
      stored_webhook = nil if stored_webhook.respond_to?(:empty?) && stored_webhook.empty?

      stored_webhook || process_options[:webhook]
    end
  end
end
