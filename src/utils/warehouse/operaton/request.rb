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
      @base_url = "#{Config::Operaton::BASE_URI}/engine-rest"
      @basic_auth = {
        username: Config::Operaton::USER_ID,
        password: Config::Operaton::PASSWORD_SECRET
      }

      def self.execute(endpoint:, method: :get, query_params: {}, body: {})
        url = "#{@base_url}/#{endpoint}"
        options = build_request_options(method: method, query: query_params, body: body)
        HTTParty.public_send(method, url, options)
      end

      class << self
        private

        def build_request_options(method:, query:, body:)
          options = {
            query: query,
            timeout: 20,
            basic_auth: @basic_auth
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
