# frozen_string_literal: true

# Simple OAuth2 Client Credentials GET wrapper

require 'httparty'
require 'json'
require_relative 'config'

module ApexClient
  APEX_OAUTH_BASE    = ENV.fetch('APEX_OAUTH_BASE')
  APEX_API_BASE      = ENV.fetch('APEX_API_BASE')
  APEX_CLIENT_ID     = ENV.fetch('APEX_CLIENT_ID')
  APEX_CLIENT_SECRET = ENV.fetch('APEX_CLIENT_SECRET')

  # Request OAuth2 token
  def self.get_token
    url = "#{APEX_OAUTH_BASE}/oauth/token"

    res = HTTParty.post(
      url,
      basic_auth: { username: APEX_CLIENT_ID, password: APEX_CLIENT_SECRET },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
        'Accept' => 'application/json; charset=UTF-8'
      },
      body: 'grant_type=client_credentials'.encode('UTF-8')
    )

    body = res.body.to_s.force_encoding('UTF-8')
    unless body.valid_encoding?
      body = res.body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace,
                                                replace: '?')
    end

    raise "Token error (#{res.code}): #{body}" unless res.code == 200

    res.parsed_response['access_token']
  end

  # Execute GET request
  def self.apex_get(token, endpoint, params = {})
    raise 'Missing endpoint' if endpoint.nil? || endpoint.strip.empty?

    clean_endpoint = endpoint.gsub(%r{^/}, '')
    url = "#{APEX_API_BASE}/#{clean_endpoint}"

    res = HTTParty.get(
      url,
      query: params,
      headers: {
        'Authorization' => "Bearer #{token}",
        'Accept' => 'application/json; charset=UTF-8'
      }
    )

    raw = res.body.to_s
    decoded = raw.dup.force_encoding('UTF-8')
    unless decoded.valid_encoding?
      raw.encode('UTF-8', 'binary', invalid: :replace, undef: :replace,
                                    replace: '?')
    end

    res
  end

  # Public API
  def self.get(endpoint:, params: {})
    token = get_token
    apex_get(token, endpoint, params)
  end
end

# CLI mode
if __FILE__ == $0
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
