# frozen_string_literal: true

require 'logger'
require 'json'
require 'httparty'
require 'dotenv/load'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative 'config'

# Archivo de log dedicado
LOG_FILE_PATH = File.expand_path('github_issues_apex.log', __dir__)

# ---------------------------------------------------------------------------
# 1. MODULO DE UTILIDADES APEX (POST)
# ---------------------------------------------------------------------------
module Utils
  module Apex
    class Request
      include HTTParty
      base_uri ENV['APEX_API_BASE_URI'] if ENV['APEX_API_BASE_URI']

      def self.post(endpoint:, body:)
        access_token = token

        options = {
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json'
          },
          body: body.to_json,
          timeout: 20
        }

        HTTParty.post("/api/v1/#{endpoint}", options)
      end

      def self.token
        credentials = apex_credentials

        response = HTTParty.post("#{base_uri}/oauth/token", {
          basic_auth: { username: credentials[:client_id], password: credentials[:client_secret] },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=client_credentials',
          timeout: 20
        })

        raise "Error obtaining APEX token: #{response.body}" unless response.success?

        response.parsed_response['access_token']
      end

      def self.apex_credentials
        {
          client_id: ENV.fetch('APEX_CLIENT_ID') { raise KeyError, 'APEX_CLIENT_ID missing' },
          client_secret: ENV.fetch('APEX_CLIENT_SECRET') { raise KeyError, 'APEX_CLIENT_SECRET missing' }
        }
      end
    end
  end
end

# ---------------------------------------------------------------------------
# 2. IMPLEMENTACIÓN DEL BOT
# ---------------------------------------------------------------------------
class GithubIssuesApexPublisher < Bas::Bot::Base
  def process
    payload = read_response.data

    if payload.nil? || payload.empty?
      log_to_file(:warn, "Payload vacío para ID: #{read_response.id}")
      return { error: { message: 'Empty payload' } }
    end

    log_to_file(:info, "Procesando ID #{read_response.id}...")

    # Enviar a Apex
    response = Utils::Apex::Request.post(
      endpoint: process_options[:apex_endpoint],
      body: payload
    )

    # Intentamos parsear, si falla forzamos string seguro
    response_body = parse_json_safely(response.body)

    if response.success?
      log_to_file(:info, "Enviado correctamente a Apex (ID: #{read_response.id})")
      { success: true, apex_response: response_body, status: response.code }
    else
      log_to_file(:error, "Error Apex (ID: #{read_response.id}): #{response.code} - #{response_body}")
      { error: { message: 'Apex failed', body: response_body, status: response.code } }
    end
  rescue StandardError => e
    log_to_file(:error, "Excepción en proceso (ID: #{read_response.id}): #{e.message}")
    { error: { message: e.message } }
  end

  def write
    result = process_response
    
    # Determinar estado para la DB
    if result.key?(:error)
      new_stage = 'error'
      apex_data = result[:error]
    else
      new_stage = 'processed'
      apex_data = result[:apex_response]
    end

    # Convertimos a JSON de forma segura
    json_data = apex_data.to_json rescue { raw: apex_data.to_s }.to_json

    sql = <<~SQL
      UPDATE github_issues_apex 
      SET stage = $1, 
          apex_response = $2, 
          updated_at = NOW()
      WHERE id = $3
    SQL

    shared_storage.connection.exec_params(sql, [new_stage, json_data, read_response.id])
  rescue StandardError => e
    log_to_file(:error, "Error actualizando DB: #{e.message}")
  end

  private

  def parse_json_safely(body)
    JSON.parse(body)
  rescue StandardError
    # Si falla el parseo, devolvemos el string sanitizado
    body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  end

  # CORRECCIÓN CLAVE: Sanitización de encoding
  def log_to_file(level, message)
    # Forzamos que el mensaje sea UTF-8 válido, reemplazando caracteres raros
    safe_message = message.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    
    # Abrimos el archivo especificando encoding externo
    File.open(LOG_FILE_PATH, 'a:UTF-8') do |f|
      f.puts("[#{level.upcase}] #{Time.now.utc} #{safe_message}")
    end
  end
end

# ---------------------------------------------------------------------------
# 3. CONFIGURACIÓN Y EJECUCIÓN SILENCIOSA
# ---------------------------------------------------------------------------

read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues_apex',
  select: "id, data",
  where: "stage='unprocessed' AND tag=$1 ORDER BY inserted_at ASC",
  params: ['FormatGithubIssuesApex']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues_apex',
  tag: 'GithubIssuesSyncToApex'
}

options = {
  avoid_empty_data: true,
  apex_endpoint: 'tasks' 
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options: read_options, write_options: write_options })

  (1..Config::MAX_RECORDS).each do
    object = GithubIssuesApexPublisher.new(options, shared_storage)
    object.execute
    
    break if object.read_response.nil? || object.read_response.empty?
  end

rescue StandardError => e
  # CORRECCIÓN CLAVE: Sanitización en el rescue final
  safe_msg = e.message.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  
  File.open(LOG_FILE_PATH, 'a:UTF-8') do |f|
    f.puts("[CRITICAL ERROR] #{Time.now.utc} #{safe_msg}")
  end
ensure
  shared_storage&.close_connections
end