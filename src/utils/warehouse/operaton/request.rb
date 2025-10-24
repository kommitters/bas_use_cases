# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative '../../../use_cases_execution/warehouse/config'

module Utils
  module Operaton
    ##
    # Encapsulates API calls to the Operaton service.
    class Request
      include HTTParty
      class << self
        def execute(endpoint:, method: :get, query_params: {}, body: {})
          url = "#{base_url}/#{endpoint}"
          options = build_request_options(method: method, query: query_params, body: body)
          HTTParty.public_send(method, url, options)
        end

        def base_url
          @base_url ||= begin
            base_uri = Config::Operaton::BASE_URI
            raise 'Operaton BASE_URI not configured' if base_uri.nil? || base_uri.empty?

            "#{base_uri}/engine-rest"
          end
        end

        def basic_auth
          @basic_auth ||= begin
            user_id = Config::Operaton::USER_ID
            password = Config::Operaton::PASSWORD_SECRET
            raise 'Operaton credentials not configured' if user_id.nil? || password.nil?

            { username: user_id, password: password }
          end
        end

        private

        def build_request_options(method:, query:, body:)
          options = {
            query: query,
            timeout: 20,
            basic_auth: basic_auth
          }

          if %i[post put patch].include?(method)
            options[:body] = body.to_json
            options[:headers] = { 'Content-Type' => 'application/json' }
          end

          options
        end
      end
    end
  end
end
