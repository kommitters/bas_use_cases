# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'
require_relative 'config'

# OAuth2 Client Credentials helper for calling APEX REST APIs.
# Provides token retrieval and sanitized GET requests.
module ApexClient
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 15
  APEX_OAUTH_BASE    = Config::APEX_OAUTH_BASE
  APEX_API_BASE      = Config::APEX_API_BASE
  APEX_CLIENT_ID     = Config::APEX_CLIENT_ID
  APEX_CLIENT_SECRET = Config::APEX_CLIENT_SECRET

  # Internal helpers
  def self.request_token
    url = "#{APEX_OAUTH_BASE}/oauth/token"
    HTTParty.post(url, token_request_options)
  rescue SocketError, HTTParty::Error, Timeout::Error => e
    raise "Token request failed: #{e.message}"
  end

  def self.sanitize_encoding(content)
    decoded = content.dup.force_encoding('UTF-8')
    return decoded if decoded.valid_encoding?

    content.encode(
      'UTF-8',
      'binary',
      invalid: :replace,
      undef: :replace,
      replace: '?'
    )
  end

  def self.perform_get(url, token, query_params)
    HTTParty.get(url, get_request_options(token, query_params))
  rescue SocketError, HTTParty::Error, Timeout::Error => e
    raise "APEX GET failed: #{e.message}"
  end

  def self.token_request_options
    {
      basic_auth: { username: APEX_CLIENT_ID, password: APEX_CLIENT_SECRET },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
        'Accept' => 'application/json; charset=UTF-8'
      },
      body: 'grant_type=client_credentials',
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT
    }
  end

  def self.get_request_options(token, query_params)
    {
      query: query_params,
      headers: {
        'Authorization' => "Bearer #{token}",
        'Accept' => 'application/json; charset=UTF-8'
      },
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT
    }
  end

  def self.clean_endpoint(endpoint)
    raise 'Missing endpoint' if endpoint.nil? || endpoint.strip.empty?

    endpoint.gsub(%r{^/}, '')
  end

  def self.sanitize_response(response)
    sanitized_body = sanitize_encoding(response.body.to_s)
    response_copy = response.dup
    response_copy.body = sanitized_body
    response_copy
  end

  # Public interface
  def self.token
    response = request_token
    body = sanitize_encoding(response.body.to_s)

    raise "Token error (#{response.code}): #{body}" unless response.code == 200

    response.parsed_response['access_token']
  end

  def self.apex_get(token, endpoint, params = {})
    endpoint_path = clean_endpoint(endpoint)
    url = "#{APEX_API_BASE}/#{endpoint_path}"
    response = perform_get(url, token, params)
    sanitized_response = sanitize_response(response)

    unless sanitized_response.code.between?(200, 299)
      raise "APEX GET error (#{sanitized_response.code}): #{sanitized_response.body}"
    end

    sanitized_response
  end

  def self.get(endpoint:, params: {})
    apex_get(token, endpoint, params)
  end
end
