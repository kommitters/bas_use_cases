# frozen_string_literal: true

require 'bas/utils/postgres/request'

module Services
  ##
  # Telegram base service to process commands logic and common behavior
  #
  class Base
    attr_reader :config

    OBSERVED_WEBSITE_TABLE = 'observed_websites'
    WEBSITE_URL = 'url'
    CONVERSATIONS_IDS_TABLE = 'conversations'
    CONVERSATIONS_IDS_ID = 'conversation_id'
    RELATION_TABLE = 'observed_websites_conversations'

    def initialize(config)
      @config = config
    end

    protected

    def query_item(table, attribute, value)
      query = "SELECT id FROM #{table} WHERE #{attribute}='#{value}';"

      execute_query(query)
    end

    def insert_item(table, attribute, value)
      query = "INSERT INTO #{table} (#{attribute}) VALUES ('#{value}') ON CONFLICT (#{attribute}) DO NOTHING RETURNING id;" # rubocop:disable Layout/LineLength

      execute_query(query)
    end

    def execute_query(query)
      params = {
        connection: config[:connection],
        query:
      }
      Utils::Postgres::Request.execute(params)
    end
  end
end
