# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  #
  class FetchNetworksEmaillessFromNotion < Bas::Bot::Base
    def process
      response = Utils::Notion::Request.execute(params)

      if response.code == 200
        networks_list = normalize_response(response.parsed_response['results'])

        { success: { networks_list: } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
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
