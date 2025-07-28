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
    write_options = {
      connection: Config::CONNECTION,
      db_table: 'pto',
      tag: 'FetchPtosFromGoogle'
    }.freeze

    shared_storage_writter = Bas::SharedStorage::Postgres.new(write_options: write_options)

    post '/pto' do
      body = request.body.read.strip
      halt 400, json(error: 'Empty request body') if body.empty?

      data = begin
        JSON.parse(body)
      rescue StandardError
        halt(400, json(error: 'Invalid JSON format'))
      end
      halt 400, json(error: 'Missing or invalid "ptos" array') unless data.is_a?(Hash) && data['ptos'].is_a?(Array)

      shared_storage_writter.write(success: { ptos: data['ptos'] })
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
  end
end
