# frozen_string_literal: true

require 'dotenv/load'
require 'httparty'

module Utils
  module Operaton
    ##
    # Encapsulates API calls to the Operaton service.
    class Request
      include HTTParty
      base_uri ENV['OPERATON_API_BASE_URI'] if ENV['OPERATON_API_BASE_URI'] # e.g., https://<server>/ords/<schema>

      def self.execute(endpoint:, method: :get, query_params: {}, body: {})
        options = build_options(method: method, query_params: query_params, body: body)
        send(method, "/engine-rest/#{endpoint}", options)
      end

      def self.build_options(method:, query_params:, body:)
        options = default_options(query_params)

        if %i[post put patch].include?(method)
          options[:body] = body.to_json
          options[:headers] = { 'Content-Type' => 'application/json' }
        end

        options
      end

      def self.default_options(query_params)
        {
          basic_auth: credentials,
          query: query_params,
          timeout: 20
        }
      end

      ##
      # Fetches and returns Operaton credentials from environment variables.
      # Will raise an error if any variable is not set.
      #
      def self.credentials
        {
          username: ENV.fetch('OPERATON_USER_ID') do
            raise KeyError, 'OPERATON_USER_ID is not set in environment variables'
          end,
          password: ENV.fetch('OPERATON_PASSWORD_SECRET') do
            raise KeyError, 'OPERATON_PASSWORD_SECRET is not set in environment variables'
          end
        }
      end
    end
  end
end
