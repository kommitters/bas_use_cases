# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'time'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

module Routes
  # Routes::Pto defines the /pto endpoint that receives PTO data
  class Pto < Sinatra::Base
    WRITE_OPTIONS = {
      connection: Config::CONNECTION,
      db_table: 'pto',
      tag: 'FetchPtosForWorkspace'
    }.freeze

    WRITER = Bas::SharedStorage::Postgres.new(write_options: WRITE_OPTIONS)

    post '/pto' do
      body = request.body.read.to_s.strip
      halt 400, json(error: 'Empty request body') if body.empty?

      data = parse_json(body)
      validate_ptos!(data)

      WRITER.write(success: { ptos: data['ptos'] })
      status 200
      json(message: 'PTOs stored successfully')
    rescue StandardError => e
      logger.error "Failed to process PTO data: #{e.message}\n#{e.backtrace.join("\n")}"
      halt 500, json(error: 'Internal Server Error')
    end

    private

    def json(payload)
      content_type :json
      payload.to_json
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError
      halt 400, json(error: 'Invalid JSON format')
    end

    def validate_ptos!(data)
      return if data.is_a?(Hash) && data['ptos'].is_a?(Array)

      halt 400, json(error: 'Missing or invalid "ptos" array')
    end
  end
end
