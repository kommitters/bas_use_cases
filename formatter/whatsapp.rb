require_relative 'base'

module Formatter
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
      @data['entry']&.first
    end

    def conversation_id
      @data['entry']&.first['changes']&.first&.dig('value', 'messages', 0)['from']
    end

    def message
      changes = @data['entry']&.first['changes']
      return puts "Error: No messages found in changes" unless changes

      changes&.first&.dig('value', 'messages', 0)['text']&.dig('body')
    end
  end
end
