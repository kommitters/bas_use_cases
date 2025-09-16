# frozen_string_literal: true

require 'dotenv/load'
require 'httparty'

module Utils
  module Apex
    ##
    # Encapsulates API calls to the APEX service.
    class Request
      include HTTParty
      base_uri ENV['APEX_API_BASE_URI'] if ENV['APEX_API_BASE_URI'] # e.g., https://<server>/ords/<schema>

      def self.execute(endpoint:, params: {})
        access_token = token

        options = {
          headers: { 'Authorization' => "Bearer #{access_token}" },
          query: params,
          timeout: 20
        }

        get("/api/v1/#{endpoint}", options)
      end

      def self.token
        credentials = apex_credentials

        response = post('/oauth/token', {
                          basic_auth: { username: credentials[:client_id], password: credentials[:client_secret] },
                          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
                          body: 'grant_type=client_credentials',
                          timeout: 20
                        })

        raise "Error obtaining APEX token: #{response.body}" unless response.success?

        response.parsed_response['access_token']
      end

      ##
      # Fetches and returns APEX credentials from environment variables.
      # Will raise an error if any variable is not set.
      #
      def self.apex_credentials
        {
          client_id: ENV.fetch('APEX_CLIENT_ID') do
            raise KeyError, 'APEX_CLIENT_ID is not set in environment variables'
          end,
          client_secret: ENV.fetch('APEX_CLIENT_SECRET') do
            raise KeyError, 'APEX_CLIENT_SECRET is not set in environment variables'
          end
        }
      end
    end
  end
end
