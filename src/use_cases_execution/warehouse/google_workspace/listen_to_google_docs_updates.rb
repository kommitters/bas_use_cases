# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

module Routes
  # Routes::GoogleDocuments defines the /google_documents endpoint that receives Google Documents data
  class GoogleDocuments < Sinatra::Base
    def initialize(args)
      super(args)
      write_options = {
        connection: Config::CONNECTION, db_table: 'warehouse_sync', tag: 'FetchGoogleDocumentsFromWorkspace'
      }
      @shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
    end

    ##
    # POST /google_docs
    #
    # Receives Google Documents data from external sources and stores it in the warehouse sync system.
    #
    # @example Request Body
    #   {
    #     "google_documents": [
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
    # @error 400 Missing or invalid "google_documents" array
    # @error 500 Internal Server Error
    #
    # @success 200 { message: "Google documents stored successfully" }
    #
    post '/google_docs' do
      body = request.body.read.to_s
      halt 400, { error: 'Empty request body' }.to_json if body.strip.empty?

      data = JSON.parse(body)

      unless data.is_a?(Hash) && data['google_documents'].is_a?(Array)
        halt 400, { error: 'Missing or invalid "google_documents" array' }.to_json
      end

      @shared_storage_writer.write(success: { type: 'document', content: data['google_documents'] })

      status 200
      { message: 'Google documents stored successfully' }.to_json
    rescue JSON::ParserError => e
      logger.error "Invalid JSON format: #{e.message}"
      status 400
      { error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      logger.error "Failed to process Google documents data: #{e.message}\n#{e.backtrace.join("\n")}"
      halt 500, { error: 'Internal Server Error' }.to_json
    end
  end
end
