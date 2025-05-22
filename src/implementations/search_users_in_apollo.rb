# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::SearchUsersInApollo class serves as a bot implementation to fetch "networks"
  # pages without emails from notion
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "FetchNetworksEmaillessFromNotion"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "SearchUsersInApollo"
  #   }
  #
  #   options = {
  #     apollo_token: "apollo_token"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::SearchUsersInApollo.new(options, shared_storage).execute
  #
  class SearchUsersInApollo < Bas::Bot::Base
    URL = 'https://api.apollo.io/api/v1/people/bulk_match'
    BATCH_SIZE = 10

    def process
      response = apollo_fetch_emails.reject { |network| network['email'].nil? }

      if response.empty?
        { error: { message: 'no emails was found' } }
      else
        { success: { networks_list: response } }
      end
    end

    private

    def apollo_fetch_emails
      read_response.data['networks_list'].each_slice(BATCH_SIZE).flat_map do |networks|
        linkedin_urls = networks.map { |network| { linkedin_url: network['linkedin_url'] } }

        emails = fetch_networks_email(linkedin_urls)

        networks.zip(emails).map { |network, email| network.merge(email) }
      end
    end

    def fetch_networks_email(linkedin_urls)
      response = HTTParty.post(URL, headers:, query: { reveal_personal_emails: true },
                                    body: { details: linkedin_urls }.to_json)

      response.code == 200 ? response.parsed_response['matches'].map { |match| { email: match['email'] } } : []
    end

    def headers
      {
        "Content-Type": 'application/json',
        "x-api-key": process_options[:apollo_token]
      }
    end
  end
end
