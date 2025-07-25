# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'time'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../../src/implementations/fetch_pto_from_google'

module Routes
  # Routes::Pto defines the /pto endpoint that receives PTO data
  class Pto < Sinatra::Base
    post '/pto' do
      begin
        request_body = request.body.read.to_s
        data = JSON.parse(request_body)

        if request_body.strip.empty?
          status 400
          return { error: 'Empty request body' }.to_json
        end
        unless data.is_a?(Hash) && data['ptos'].is_a?(Array)
          status 400
          return { error: 'Missing or invalid "ptos" array' }.to_json
        end

        write_options = {
          connection: Config::CONNECTION,
          db_table: 'pto',
          tag: 'FetchPtosForWorkspace'
        }

        shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
        shared_storage_writer.write(success: { ptos: data['ptos'] })

        status 200
        { message: 'PTOs stored successfully' }.to_json
      rescue StandardError => e
        logger.error "Failed to process PTO data: #{e.message}"
        status 500
        { error: 'Internal Server Error' }.to_json
      end
    end
  end
end
