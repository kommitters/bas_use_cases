# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::FetchNetworksFromNotion class serves as a bot implementation to read networks
  # with emails from a notion table and saves them in a PostgresDB shared storage
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: 'apollo_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchNetworksFromNotion']
  #   }
  #
  #   write_options = {
  #     connection: ,
  #     db_table: 'apollo_sync',
  #     tag: 'FetchNetworksFromNotion'
  #   }
  #
  #   options = {
  #     database_id: 'notion database id',
  #     secret: 'notion secret'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FetchNetworksFromNotion.new(options, shared_storage).execute
  #
  class FetchNetworksFromNotion < Bas::Bot::Base
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
      { filter: { and: [{ property: 'Email', email: { is_not_empty: true } }] + date_filter } }
    end

    def date_filter
      return [] if read_response.inserted_at.nil?

      [{ timestamp: :last_edited_time,
         last_edited_time: { on_or_after: read_response.inserted_at } }]
    end

    def normalize_response(networks)
      networks.map do |network|
        properties = network['properties']

        {
          email: properties['Email']['email'],
          linkedin_url: properties['LinkedIn']['url'],
          industry_networking: extract_industry_networking(properties['Industry (Networking)']),
          role: extract_role(properties['Role']), country: extract_country(properties['Country']),
          qualification: extract_qualification(properties['Qualification'])
        }
      end
    end

    def extract_name(name)
      name['title'].map { |title| title['text']['content'] }.join(' ')
    end

    def extract_industry_networking(industry_networking)
      industry_networking['multi_select'].map { |select| select['name'] }.join(' ')
    end

    def extract_role(roles)
      roles['multi_select'].map { |role| role['name'] }.join(' ')
    end

    def extract_country(countries)
      countries['multi_select'].map { |country| country['name'] }.join(' ')
    end

    def extract_qualification(qualification)
      return '' if qualification['select'].nil?

      qualification['select']['name']
    end
  end
end
