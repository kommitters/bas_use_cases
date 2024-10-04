# frozen_string_literal: true

require_relative 'base'

module Services
  class ListWebsites < Services::Base
    def execute
      user_websites.values.flatten
    end

    private

    def user_websites
      query = """
        SELECT url 
        FROM 
          telegram_chats 
          JOIN websites_telegram_chats on telegram_chats.id = telegram_chat_id 
          JOIN websites on websites.id = website_id 
        WHERE chat_id = '#{config[:chat_id]}';
      """

      execute_query(query)
    end
  end
end
