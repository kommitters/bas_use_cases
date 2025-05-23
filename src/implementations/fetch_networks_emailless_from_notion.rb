# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::FetchNetworksEmaillessFromNotion class serves as a bot implementation to fetch "networks"
  # pages without emails from notion
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "FetchNetworksEmaillessFromNotion"
  #   }
  #
  #   options = {
  #     database_id: "database_id"
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FetchNetworksEmaillessFromNotion.new(options, shared_storage).execute
  #
  class FetchNetworksEmaillessFromNotion < Bas::Bot::Base
    def process
      response = Utils::Notion::Request.execute(params)

      if response.code == 200
        networks_list = normalize_response(response.parsed_response['results'])
        networks_list += fetch_all_networks(response) if response.parsed_response['has_more']

        { success: { networks_list: } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def fetch_all_networks(response)
      networks_list = []

      loop do
        break unless response['has_more']

        response = Utils::Notion::Request.execute(next_cursor_params(response['next_cursor']))
        networks_list += normalize_response(response.parsed_response['results']) if response.code == 200
      end

      networks_list
    end

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
    end

    def next_cursor_params(next_cursor)
      next_cursor_body = body.merge({ start_cursor: next_cursor })

      params.merge(body: next_cursor_body)
    end

    def body
      { filter: { property: 'Email', email: { is_empty: true } } }
    end

    def normalize_response(networks)
      networks.map do |network|
        properties = network['properties']

        { id: network['id'], linkedin_url: properties['LinkedIn']['url'] }
      end
    end
  end
end
