# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # Telegram service to list websites associated to a user
  # when a user execute the /list_websites command.
  #
  class ListWebsites < Services::Base
    def execute
      user_websites
    end

    private

    def user_websites
      query = "SELECT url FROM (conversations JOIN observed_websites_conversations ON conversations.id = observed_websites_conversations.conversation_id JOIN observed_websites ON observed_websites.id = observed_websites_conversations.observed_website_id) WHERE conversations.conversation_id = '#{config[:conversation_id]}';" # rubocop:disable Layout/LineLength
      execute_query(query)
    end
  end
end
