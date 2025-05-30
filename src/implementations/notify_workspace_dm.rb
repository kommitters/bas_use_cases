# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../utils/send_message_to_workspace'

module Implementation
  ##
  # The Implementation::NotifyWorkspace class serves as a bot implementation to send messages to a
  # Google Chat workspace read from a PostgresDB table using Google Chat API.
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
  #
  #   }
  #
  #  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyWorkspace.new(options, shared_storage).execute
  #
  class NotifyWorkspaceDm < Bas::Bot::Base
    # process function to execute the Google Chat utility to send the notification
    #
    def process
      return { success: {} } if unprocessable_response

      space_id = read_response.data['dm_id']

      message = read_response.data['notification']

      begin
        sender = Utils::GoogleChat::SendMessageToWorkspace.new(space_id: space_id)
        sender.send_text_message(message)

        { success: {} }
      rescue StandardError => e
        { error: { message: e.message, status_code: e.status_code || 500 } }
      end
    end
  end
end
