# frozen_string_literal: true

require 'httparty'
require_relative '../../../use_cases_execution/warehouse/config'

module Utils
  module Operaton
    ##
    # Encapsulates API calls to the Operaton service.
    class Request
      include HTTParty
      base_uri Config::Operaton::BASE_URI if Config::Operaton::BASE_URI

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
          username: Config::Operaton::USER_ID,
          password: Config::Operaton::PASSWORD_SECRET
        }
      end
    end
  end
end
