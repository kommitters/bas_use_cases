# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # Telegram service to remove association between users and domains
  # when the user execute the /remove_webiste command
  #
  class RemoveWebsite < Services::Base
    def execute
      delete_website(website_id, conversation_id)
    end

    private

    def website_id
      observed_website = query_item(OBSERVED_WEBSITE_TABLE, WEBSITE_URL, config[:website])

      observed_website.first['id']
    end

    def conversation_id
      chat = query_item(CONVERSATIONS_IDS_TABLE, CONVERSATIONS_IDS_ID, config[:conversation_id])

      chat.first['id']
    end

    def delete_website(website_id, conversation_id)
      query = "DELETE FROM observed_websites_conversations WHERE observed_website_id = #{website_id} AND conversation_id = #{conversation_id};" # rubocop:disable Layout/LineLength

      execute_query(query)
    end
  end
end
