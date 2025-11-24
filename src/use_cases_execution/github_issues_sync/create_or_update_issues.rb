# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

load File.expand_path('../../utils/apex/apex_post_general.rb', __dir__)
require_relative 'config'

ENDPOINT = "tasks"

READ_OPTIONS = {
  connection: Config::CONNECTION,
  db_table:   'github_issues_apex',
  select:     "id, data",
  where:      "stage='unprocessed' AND tag=$1 ORDER BY inserted_at ASC",
  params:     ['FormatGithubIssuesApex']
}

WRITE_OPTIONS = {
  connection: Config::CONNECTION,
  db_table:   'github_issues_apex',
  tag:        'GithubIssuesSyncToApex'
}

logger = Logger.new($stdout)

begin
  storage = Bas::SharedStorage::Postgres.new(
    read_options:  READ_OPTIONS,
    write_options: WRITE_OPTIONS
  )

  (1..Config::MAX_RECORDS).each do
    # ===========================================
    # LEER CORRECTAMENTE
    # (esto avanza cursor, read NO lo hace)
    # ===========================================
    row = storage.read_response
    break if row.nil? || row.data.nil?

    issue_id = row.id
    payload  = row.data

    # ===========================================
    # VALIDACIÓN
    # ===========================================
    unless payload.is_a?(Hash) &&
           payload.key?("name") &&
           payload.key?("description") &&
           payload.key?("status")

      logger.info("ID #{issue_id} → SKIPPED (invalid payload)")

      storage.write_response(
        id: issue_id,
        success: {
          stage: "processed",
          apex_response: "skipped_invalid_format"
        }
      )

      next
    end

    # ===========================================
    # POST APEX
    # ===========================================
    logger.info("Procesando ID #{issue_id}")

    token    = get_token
    response = apex_post(token, ENDPOINT, payload)
    stage    = response.success? ? "processed" : "error"

    safe_body = response.body.to_s.encode(
      "UTF-8",
      invalid: :replace,
      undef:   :replace,
      replace: "?"
    )

    # ===========================================
    # GUARDAR RESULTADO (MISMA FILA)
    # ===========================================
    storage.write_response(
      id: issue_id,
      success: {
        stage:         stage,
        apex_response: safe_body
      }
    )

    logger.info("ID #{issue_id} → #{stage}")
  end

  storage.close_connections

rescue => e
  storage&.close_connections
  logger.error("FATAL: #{e.message}")
end
