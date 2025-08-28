# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../config'
require_relative '../../../utils/warehouse/google_workspace/kpis_format'

module Routes
  # Routes::Kpis defines the /kpis endpoint
  class Kpis < Sinatra::Base
    def initialize(args)
      super(args)
      write_options = {
        connection: Config::Database::CONNECTION,
        db_table: 'warehouse_sync',
        tag: 'FetchKpisFromWebhook'
      }
      @shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
    end

    ##
    # POST /kpis
    #
    # Receives raw Google Sheet data, formats it using a dedicated formatter, and stores it.
    #
    post '/kpis' do
      body = request.body.read.to_s
      halt 400, { error: 'Empty request body' }.to_json if body.strip.empty?
      data = JSON.parse(body)

      unless data.is_a?(Hash) && data['key_performance_raw'].is_a?(Array)
        halt 400, { error: 'Missing or invalid "key_performance_raw" array' }.to_json
      end

      raw_data = data['key_performance_raw']
      halt 400, { error: 'Input data must have a header and at least one data row.' }.to_json unless raw_data.length > 1

      data_rows = raw_data.slice(1..-1)

      formatted_kpis = data_rows.map do |row|
        Utils::Warehouse::GoogleWorkspace::KpisFormatter.new(row).format
      end.compact

      @shared_storage_writer.write(success: { type: 'kpi',
                                              content: formatted_kpis })

      status 200
      { message: 'KPIs stored successfully' }.to_json
    rescue JSON::ParserError => e
      logger.error "Invalid JSON format: #{e.message}"
      status 400
      { error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      logger.error "Failed to process KPIs data: #{e.message}\n#{e.backtrace.join("\n")}"
      halt 500, { error: 'Internal Server Error' }.to_json
    end
  end
end
