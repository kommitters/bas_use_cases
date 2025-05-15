# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  #
  class SearchUsersInApollo < Bas::Bot::Base
    URL = 'https://api.apollo.io/api/v1/people/match'

    def process
      response = apollo_fetch_emails.compact

      if response.empty?
        { error: { message: 'no emails was found' } }
      else
        { success: { networks_list: response } }
      end
    end

    private

    def apollo_fetch_emails
      read_response.data['networks_list'].map do |network|
        email = fetch_single_email(network['linkedin_url'])

        email.nil? ? nil : network.merge({ 'email': email })
      end
    end

    def fetch_single_email(linkedin_url)
      response = HTTParty.get(URL, headers:, query: { linkedin_url: linkedin_url })

      response.code == 200 ? response.parsed_response['person']['email'] : nil
    end

    def headers
      {
        "Content-Type": 'application/json',
        "x-api-key": process_options[:apollo_token]
      }
    end
  end
end
