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
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }

        # Performs the GET request to the specific endpoint.
        HTTParty.get("#{base_url}/api/v1/work-logs", headers: headers, query: params)
      end
    end
  end
end
