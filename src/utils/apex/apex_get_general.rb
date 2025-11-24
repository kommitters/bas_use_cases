# frozen_string_literal: true
# General GET client using OAuth2 Client Credentials (PDF) — UTF-8 SAFE
# Logs always work (CLI + programmatic)

require 'httparty'
require 'json'
require 'dotenv'
Dotenv.load(File.join(__dir__, '.env'))

module ApexClient
  APEX_OAUTH_BASE    = ENV.fetch("APEX_OAUTH_BASE")
  APEX_API_BASE      = ENV.fetch("APEX_API_BASE")
  APEX_CLIENT_ID     = ENV.fetch("APEX_CLIENT_ID")
  APEX_CLIENT_SECRET = ENV.fetch("APEX_CLIENT_SECRET")

  LOG_FILE = File.join(__dir__, "apex_get_general.log")

  # -------------------------------------------------------------
  # LOG (UTF-8 safe) — module-scoped for reliable lookup
  # -------------------------------------------------------------
  def self.log(msg)
    safe = msg.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
    File.open(LOG_FILE, "a", encoding: "UTF-8") do |f|
      f.puts("[#{Time.now.utc}] #{safe}")
    end
  rescue => e
    # If file logging fails, at least show it in stdout
    warn "LOGGING FAILED: #{e.message}"
  end

  # -------------------------------------------------------------
  # TOKEN REQUEST
  # -------------------------------------------------------------
  def self.get_token
    url = "#{APEX_OAUTH_BASE}/oauth/token"
    log "POST TOKEN → #{url}"

    res = HTTParty.post(
      url,
      basic_auth: { username: APEX_CLIENT_ID, password: APEX_CLIENT_SECRET },
      headers: {
        "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
        "Accept"       => "application/json; charset=UTF-8"
      },
      body: "grant_type=client_credentials".encode("UTF-8")
    )

    log "TOKEN CODE: #{res.code}"

    body = res.body.to_s.force_encoding("UTF-8")
    body = res.body.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "?") unless body.valid_encoding?
    log "TOKEN BODY: #{body}"

    raise "Token error (#{res.code}): #{body}" unless res.code == 200
    res.parsed_response["access_token"]
  end

  # -------------------------------------------------------------
  # GENERAL GET
  # -------------------------------------------------------------
  def self.apex_get(token, endpoint, params = {})
    raise "Missing endpoint" if endpoint.nil? || endpoint.strip.empty?

    clean_endpoint = endpoint.gsub(/^\//, "")
    url = "#{APEX_API_BASE}/#{clean_endpoint}"

    log "GET → #{url} | params=#{params}"

    res = HTTParty.get(
      url,
      query: params,
      headers: {
        "Authorization" => "Bearer #{token}",
        "Accept"        => "application/json; charset=UTF-8"
      }
    )

    raw = res.body.to_s
    decoded = raw.dup.force_encoding("UTF-8")
    decoded = raw.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "?") unless decoded.valid_encoding?

    log "GET CODE: #{res.code}"
    log "GET BODY: #{decoded}"

    res
  end

  # -------------------------------------------------------------
  # PUBLIC API (programmatic)
  # -------------------------------------------------------------
  def self.get(endpoint:, params: {})
    log "===== APEXCLIENT START ====="
    token = get_token
    log "Token OK from ApexClient"
    res = apex_get(token, endpoint, params)
    log "===== APEXCLIENT END ====="
    res
  end
end

# -------------------------------------------------------------
# CLI MODE
# ruby apex_get_general.rb taskman_pto key=value
# -------------------------------------------------------------
if __FILE__ == $0
  endpoint = ARGV.shift.to_s

  if endpoint.strip.empty?
    puts "ERROR: Missing endpoint name"
    puts "Usage: ruby apex_get_general.rb taskman_pto"
    exit 1
  end

  params = {}
  ARGV.each do |arg|
    k, v = arg.split("=", 2)
    params[k.to_sym] = v if v
  end

  begin
    ApexClient.log "===== START GENERAL GET (CLI) ====="
    ApexClient.get(endpoint: endpoint, params: params)
  rescue => e
    ApexClient.log "ERROR: #{e.message}"
    ApexClient.log e.backtrace.join("\n")
  end
  ApexClient.log "===== END GENERAL GET (CLI) ====="
end
