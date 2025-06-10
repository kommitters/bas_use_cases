# frozen_string_literal: true

require 'bas/utils/notion/request'

module Utils
  module Notion
    ##
    # This module creates a new entry under a Notion database
    #
    class CreateNotionDbEntry
      def initialize(secret, database_id, issue_data)
        @secret = secret
        @issue_data = issue_data
        @database_id = database_id
      end

      def execute
        Utils::Notion::Request.execute(params)
      end

      private

      def params
        {
          endpoint: 'pages',
          secret: @secret,
          method: 'post',
          body: build_notion_payload
        }
      end

      def build_notion_payload
        raise ArgumentError, "Expected Hash, got #{@issue_data.class}" unless @issue_data.is_a?(Hash)

        {
          parent: { database_id: @database_id },
          properties: @issue_data.except('children'),
          children: @issue_data['children'] || []
        }
      end
    end
  end
end
