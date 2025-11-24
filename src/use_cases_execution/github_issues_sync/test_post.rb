# test_apex_basic_auth.rb
# Independiente, usa dotenv, Basic Auth, Logs seguros UTF-8.

require 'httparty'
require 'json'
require 'dotenv'

# -------------------------------------------------------------------
# Cargar .env desde la MISMA carpeta del script
# -------------------------------------------------------------------
Dotenv.load(File.join(__dir__, '.env'))

# -------------------------------------------------------------------
# Variables de entorno (usar usuario de SCHEMA, NO OAuth)
# -------------------------------------------------------------------
APEX_BASE_URI   = ENV.fetch('APEX_API_BASE_URI')   # https://oracleapex.com/ords/kommit
APEX_USERNAME   = ENV.fetch('APEX_USERNAME')       # ← usuario REAL del esquema
APEX_PASSWORD   = ENV.fetch('APEX_PASSWORD')       # ← contraseña REAL del esquema
APEX_ENDPOINT   = ENV.fetch('APEX_ENDPOINT', 'tasks')

LOG_FILE = File.join(__dir__, "apex_basic_auth_test.log")

# -------------------------------------------------------------------
# Log seguro UTF-8
# -------------------------------------------------------------------
def log(msg)
  safe = msg.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  File.open(LOG_FILE, "a:UTF-8") do |f|
    f.puts("[#{Time.now.utc}] #{safe}")
  end
end

# -------------------------------------------------------------------
# GET con Basic Auth
# -------------------------------------------------------------------
def apex_get(endpoint, params = {})
  url = "#{APEX_BASE_URI}/api/v1/#{endpoint}"

  log "GET → #{url} PARAMS → #{params}"

  response = HTTParty.get(
    url,
    query: params,
    basic_auth: {
      username: APEX_USERNAME,
      password: APEX_PASSWORD
    },
    headers: {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  )

  log "GET RESPONSE CODE: #{response.code}"
  log "GET RESPONSE BODY: #{response.body}"

  response
end

# -------------------------------------------------------------------
# POST con Basic Auth
# -------------------------------------------------------------------
def apex_post(endpoint, payload)
  url = "#{APEX_BASE_URI}/api/v1/#{endpoint}"

  log "POST → #{url}"
  log "PAYLOAD → #{payload.to_json}"

  response = HTTParty.post(
    url,
    basic_auth: {
      username: APEX_USERNAME,
      password: APEX_PASSWORD
    },
    headers: {
      "Content-Type" => "application/json",
      "Accept"        => "application/json"
    },
    body: payload.to_json
  )

  log "POST RESPONSE CODE: #{response.code}"
  log "POST RESPONSE BODY: #{response.body}"

  response
end

# -------------------------------------------------------------------
# Ejecución
# -------------------------------------------------------------------
begin
  log "===== INICIO DEL TEST BASIC AUTH ====="

  # --------------------------------------------------
  # TEST GET (activities)
  # --------------------------------------------------
  log "Probando GET /activities"
  apex_get("activities", {
    last_edited_time: "2025-09-01T14:30:00Z"
  })

  # --------------------------------------------------
  # TEST POST (tasks)
  # --------------------------------------------------
  payload = {
    name:        "Standalone BasicAuth Test",
    description: "Task creada con Basic Auth",
    status:      "BACKLOG",
    deadline:    "2025-09-30",
    comment:     "Test desde script Basic Auth"
  }

  log "Probando POST /tasks"
  apex_post("tasks", payload)

rescue => e
  log "ERROR → #{e.message}"
  log e.backtrace.join("\n")
end

log "===== FIN DEL TEST BASIC AUTH ====="
