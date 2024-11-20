require_relative 'base'

module Formatters
  class WhatsAppFormatter < Base
    def process(data)
      format(data)
      entry = data['entry']&.first
      changes = entry['changes']&.first&.dig('value', 'messages', 0)
      return puts "Error: No messages found in changes" unless changes
      id = entry['id']
      conversation_id = changes['from']
      message = changes['text']&.dig('body')
      {
        id: id,
        conversation_id: conversation_id,
        message: message
      }
    end
  end
end
