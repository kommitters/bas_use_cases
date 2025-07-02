# frozen_string_literal: true

require 'httparty'
require 'json'

module Utils
  module WorkLogs
    # Encapsulates API calls to the WorkLogs service.
    class Request
      # Executes the request to fetch work logs from the API.
      # It receives the base URL, token, and query parameters dynamically.
      def self.execute(base_url:, token:, params:)
        raise ArgumentError, 'base_url is required' if base_url.nil? || base_url.empty?
        raise ArgumentError, 'token is required' if token.nil? || token.empty?

        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }

        # Performs the GET request to the specific endpoint.
        HTTParty.get("#{base_url}/api/v1/work-logs", headers: headers, query: params)
      rescue HTTParty::Error, StandardError => e
        raise "Failed to fetch work logs: #{e.message}"
      end
    end
  end
end
