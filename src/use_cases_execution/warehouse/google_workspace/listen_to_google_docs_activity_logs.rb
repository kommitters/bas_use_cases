# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../config'

module Routes
  # Routes::GoogleDocumentsActivityLogs defines the /google_docs_activity_logs endpoint that receives
  # Google Documents activity logs from external sources and stores it in the warehouse sync system.
  class GoogleDocumentsActivityLogs < Sinatra::Base
    MAX_SIZE = 10_485_760 # 10MB
    PAYLOAD_SIZE_ERROR = 'Request too large (10MB max)'

    def initialize(args)
      super(args)
      write_options = {
        connection: Config::Database::CONNECTION,
        db_table: 'warehouse_sync',
        tag: 'FetchGoogleDocumentsActivityLogsFromWorkspace'
      }
      @shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
      @token = ENV.fetch('WEBHOOK_TOKEN') do
        raise ArgumentError, 'WEBHOOK_TOKEN environment variable is required to listed to google_docs_activity_logs'
      end
    end

    ##
    # POST /google_docs_activity_logs
    #
    # Receives Google Documents activity logs from external sources and stores it in the warehouse sync system.
    #
    # @example Request Body
    #   {
    #     "google_docs_activity_logs": [
    #       {
    #         "external_document_id": "document_id",
    #         "name": "Document Title",
    #         "external_domain_id": "domain_id"
    #       }
    #     ]
    #   }
    #
    # @return [Hash] JSON response indicating success or failure
    # @return [Integer] HTTP status code
    #
    # @error 400 Empty request body
    # @error 400 Invalid JSON format
    # @error 400 Missing or invalid "google_docs_activity_logs" array
    # @error 500 Internal Server Error
    #
    # @success 200 { message: "Google documents activity logs stored successfully" }
    #
    post '/google_docs_activity_logs' do
      validate_content_length!

      body = request.body.read.to_s
      halt 400, { error: 'Empty request body' }.to_json if body.strip.empty?

      data = JSON.parse(body)

      auth_header = request.env['HTTP_AUTHORIZATION']
      if auth_header.nil? || !auth_header.start_with?('Bearer ')
        halt 401, { error: 'Missing or invalid Authorization header' }.to_json
      end

      token = auth_header.split(' ').last
      halt 403, { error: 'Forbidden: invalid token' }.to_json unless token == @token

      unless data.is_a?(Hash) && data['google_docs_activity_logs'].is_a?(Array)
        halt 400, { error: 'Missing or invalid "google_docs_activity_logs" array' }.to_json
      end

      @shared_storage_writer.write(success: { type: 'document_activity_log',
                                              content: data['google_docs_activity_logs'] })

      status 200
      { message: 'Google documents activity logs stored successfully' }.to_json
    rescue JSON::ParserError => e
      logger.error "Invalid JSON format: #{e.message}"
      status 400
      { error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      logger.error "Failed to process Google documents activity logs data: #{e.message}\n#{e.backtrace.join("\n")}"
      puts "ERROR: #{e.class}: #{e.message}"
      halt 500, { error: 'Internal Server Error' }.to_json
    end

    private

    def validate_content_length!
      return unless request.content_length && request.content_length.to_i > MAX_SIZE

      halt 413, { error: PAYLOAD_SIZE_ERROR }.to_json
    end
  end
end
