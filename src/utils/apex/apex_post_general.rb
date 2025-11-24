# apex_post_general.rb

require 'httparty'
require 'json'
require 'dotenv'

Dotenv.load(File.join(__dir__, '.env'))

APEX_OAUTH_BASE    = ENV.fetch("APEX_OAUTH_BASE")
APEX_API_BASE      = ENV.fetch("APEX_API_BASE")
APEX_CLIENT_ID     = ENV.fetch("APEX_CLIENT_ID")
APEX_CLIENT_SECRET = ENV.fetch("APEX_CLIENT_SECRET")

LOG_FILE = File.join(__dir__, "apex_post_general.log")

# ----------------------------------------------------------
# LOG seguro UTF-8
# ----------------------------------------------------------
def log(msg)
  safe = msg.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  File.open(LOG_FILE, "a", encoding: "UTF-8") do |f|
    f.puts("[#{Time.now.utc}] #{safe}")
  end
end

# ----------------------------------------------------------
# TOKEN (OAuth client_credentials)
# ----------------------------------------------------------
def get_token
  url = "#{APEX_OAUTH_BASE}/oauth/token"
  log "TOKEN POST → #{url}"

  res = HTTParty.post(
    url,
    basic_auth: { username: APEX_CLIENT_ID, password: APEX_CLIENT_SECRET },
    headers: {
      "Content-Type" => "application/x-www-form-urlencoded",
      "Accept"       => "application/json"
    },
    body: "grant_type=client_credentials"
  )

  log "TOKEN CODE: #{res.code}"
  log "TOKEN BODY: #{res.body}"

  raise "Token error #{res.code}" unless res.code == 200

  res.parsed_response["access_token"]
end

# ----------------------------------------------------------
# POST a ORDS /api/v1/<endpoint>
# ----------------------------------------------------------
def apex_post(token, endpoint, payload)
  raise "Missing endpoint" if endpoint.to_s.strip.empty?

  endpoint = endpoint.gsub(/^\//, "")
  url = "#{APEX_API_BASE}/#{endpoint}"

  safe_payload = payload.to_json.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")

  log "POST → #{url}"
  log "PAYLOAD → #{safe_payload}"

  res = HTTParty.post(
    url,
    headers: {
      "Authorization" => "Bearer #{token}",
      "Content-Type"  => "application/json",
      "Accept"        => "application/json"
    },
    body: safe_payload
  )

  decoded = res.body.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")

  log "POST CODE: #{res.code}"
  log "POST BODY: #{decoded}"

  res
end
