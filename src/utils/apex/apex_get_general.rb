# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

# OAuth2 Client Credentials helper for calling APEX REST APIs.
# Provides token retrieval and sanitized GET requests.
module ApexClient
  APEX_OAUTH_BASE    = ENV.fetch('APEX_OAUTH_BASE')
  APEX_API_BASE      = ENV.fetch('APEX_API_BASE')
  APEX_CLIENT_ID     = ENV.fetch('APEX_CLIENT_ID')
  APEX_CLIENT_SECRET = ENV.fetch('APEX_CLIENT_SECRET')

  # Internal helpers
  def self.request_token
    url = "#{APEX_OAUTH_BASE}/oauth/token"

    HTTParty.post(
      url,
      basic_auth: { username: APEX_CLIENT_ID, password: APEX_CLIENT_SECRET },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
        'Accept' => 'application/json; charset=UTF-8'
      },
      body: 'grant_type=client_credentials'
    )
  end

  def self.sanitize_encoding(raw)
    decoded = raw.dup.force_encoding('UTF-8')
    return decoded if decoded.valid_encoding?

    raw.encode(
      'UTF-8',
      'binary',
      invalid: :replace,
      undef: :replace,
      replace: '?'
    )
  end

  def self.perform_get(url, token, params)
    HTTParty.get(
      url,
      query: params,
      headers: {
        'Authorization' => "Bearer #{token}",
        'Accept' => 'application/json; charset=UTF-8'
      }
    )
  end

  def self.clean_endpoint(endpoint)
    raise 'Missing endpoint' if endpoint.nil? || endpoint.strip.empty?

    endpoint.gsub(%r{^/}, '')
  end

  def self.sanitize_response(res)
    cleaned = sanitize_encoding(res.body.to_s)
    res.body.replace(cleaned)
    res
  end

  # Public interface
  def self.token
    res = request_token
    body = sanitize_encoding(res.body.to_s)

    raise "Token error (#{res.code}): #{body}" unless res.code == 200

    res.parsed_response['access_token']
  end

  def self.apex_get(token, endpoint, params = {})
    clean = clean_endpoint(endpoint)
    url   = "#{APEX_API_BASE}/#{clean}"
    res   = perform_get(url, token, params)
    sanitize_response(res)
  end

  def self.get(endpoint:, params: {})
    apex_get(token, endpoint, params)
  end
end

# CLI mode
if __FILE__ == $PROGRAM_NAME
  endpoint = ARGV.shift.to_s

  if endpoint.strip.empty?
    puts 'ERROR: Missing endpoint name'
    puts 'Usage: ruby apex_get_general.rb taskman_pto'
    exit 1
  end

  params = {}
  ARGV.each do |arg|
    k, v = arg.split('=', 2)
    params[k.to_sym] = v if v
  end

  begin
    ApexClient.get(endpoint: endpoint, params: params)
  rescue StandardError => e
    warn "ERROR: #{e.message}"
    warn e.backtrace.join("\n")
  end
end
