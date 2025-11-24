# frozen_string_literal: true

require 'dotenv/load'
require 'httparty'

module Utils
  module Apex
    ##
    # Encapsulates POST calls to the APEX service.
    class Request
      include HTTParty

      # Validate and sanitize base URI
      raw_base = ENV['APEX_API_BASE_URI']

      if raw_base.nil? || raw_base.empty?
        raise "APEX_API_BASE_URI is missing"
      end

      # Prevent using an incorrect base URI like /ords/schema/api/v1
      if raw_base.include?("/api/v1")
        raise "APEX_API_BASE_URI must NOT include '/api/v1'. Use base ORDS schema only, e.g. https://server/ords/schema"
      end

      base_uri raw_base

      ##
      # Performs a POST request against /api/v1/<endpoint>
      #
      def self.execute(endpoint:, body:)
        access_token = token

        options = {
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json'
          },
          body: body.to_json,
          timeout: 20
        }

        # Final URL = <base_uri>/api/v1/<endpoint>
        post("/api/v1/#{endpoint}", options)
      end

      ##
      # Issues OAuth2 client_credentials token request.
      #
      def self.token
        credentials = apex_credentials

        response = post('/oauth/token', {
          basic_auth: {
            username: credentials[:client_id],
            password: credentials[:client_secret]
          },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=client_credentials',
          timeout: 20
        })

        unless response.success?
          raise "Error obtaining APEX token: #{response.body}"
        end

        response.parsed_response['access_token']
      end

      ##
      # Fetches APEX credentials from environment variables.
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
