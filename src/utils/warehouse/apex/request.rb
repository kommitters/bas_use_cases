# frozen_string_literal: true

require 'dotenv/load'
require 'httparty'

module Utils
  module Apex
    ##
    # Encapsulates API calls to the APEX service.
    class Request
      include HTTParty
      base_uri ENV.fetch('APEX_API_BASE_URI') # e.g., https://<server>/ords/<schema>

      def self.execute(endpoint:, params: {})
        access_token = token

        options = {
          headers: { 'Authorization' => "Bearer #{access_token}" },
          query: params
        }

        get("/api/v1/#{endpoint}", options)
      end

      def self.token
        client_id = ENV.fetch('APEX_CLIENT_ID')
        client_secret = ENV.fetch('APEX_CLIENT_SECRET')

        response = post('/oauth/token', {
                          basic_auth: { username: client_id, password: client_secret },
                          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
                          body: 'grant_type=client_credentials'
                        })

        raise "Error obtaining APEX token: #{response.body}" unless response.success?

        response.parsed_response['access_token']
      end
    end
  end
end
