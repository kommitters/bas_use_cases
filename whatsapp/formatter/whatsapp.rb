# frozen_string_literal: true

require_relative 'base'

module Formatter
  ##
  # The Formatter::Whatsapp module receives a whatsapp API response and format it
  # on a common data structure to be used by the chat-bots.
  #
  class WhatsApp < Base
    def process(data)
      @data = data

      {
        id: id,
        conversation_id: conversation_id,
        message: message
      }
    end

    private

    def id
      @data['entry']&.first&.[]('id')
    end

    def conversation_id
      changes&.first&.dig('value', 'messages', 0)&.[]('from')
    end

    def message
      return puts 'Error: No messages found in changes' unless changes

      changes&.first&.dig('value', 'messages', 0)&.[]('text')&.dig('body')
    end

    def changes
      @data['entry']&.first&.[]('changes')
    end
  end
end
