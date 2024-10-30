# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # This class is an implementation of the Write::Base interface, specifically designed
  # to wtite to a PostgresDB used as <b>common storage</b>.
  #
  class AddWebsite < Services::Base
    # Execute the Postgres utility to write data in the <b>common storage</b>
    #
    def execute
      website_id = process_website
      conversation_id = process_chat

      insert_relation(website_id, conversation_id)
    end

    private

    def process_website
      insert_item(OBSERVED_WEBSITE_TABLE, WEBSITE_URL, config[:url])

      website = query_item(OBSERVED_WEBSITE_TABLE, WEBSITE_URL, config[:url])

      website.values.first.first
    end

    def process_chat
      insert_item(CONVERSATIONS_IDS_TABLE, CONVERSATIONS_IDS_ID, config[:conversation_id])

      conversation = query_item(CONVERSATIONS_IDS_TABLE, CONVERSATIONS_IDS_ID, config[:conversation_id])

      conversation[0]['id']
    end

    def insert_relation(website_id, conversation_id)
      query = "INSERT INTO #{RELATION_TABLE}
              (observed_website_id, conversation_id) VALUES (#{website_id}, #{conversation_id});"

      execute_query(query)
    end
  end
end
