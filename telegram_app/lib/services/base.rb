# frozen_string_literal: true

require 'bas/utils/postgres/request'

module Services
  class Base
    attr_reader :config

    WEBSITE_TABLE = 'websites'
    WEBSITE_URL = 'url'
    CHATS_IDS_TABLE = 'telegram_chats'
    CHATS_IDS_ID = 'chat_id'
    RELATION_TABLE = 'websites_telegram_chats'
    
    def initialize(config)
      @config = config
    end

    protected

    def execute_query(query)
      params = {
        connection: config[:connection],
        query: 
      }

      Utils::Postgres::Request.execute(params)
    end
  end
end