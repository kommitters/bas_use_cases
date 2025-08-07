# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require_relative 'config'

module Routes
  # Routes::PtoNextWeek defines the /pto-next-week endpoint that receives PTO data
  class PtoNextWeek < Sinatra::Base
    write_options = {
      connection: Config::CONNECTION,
      db_table: 'pto',
      tag: 'FetchNextWeekPtosFromGoogle'
    }

    TOKEN = ENV.fetch('WEBHOOK_TOKEN')

    post '/pto-next-week' do
      content_type :json

      auth_header = request.env['HTTP_AUTHORIZATION']
      if auth_header.nil? || !auth_header.start_with?('Bearer ')
        halt 401, { error: 'Missing or invalid Authorization header' }.to_json
      end

      token = auth_header.split(' ').last
      halt 403, { error: 'Forbidden: invalid token' }.to_json unless token == TOKEN

      begin
        request_body = request.body.read
        halt 400, { error: 'Empty request body' }.to_json if request_body.strip.empty?

        data = JSON.parse(request_body)
        halt 400, { error: 'Invalid JSON format' }.to_json unless data.is_a?(Hash) && !data.empty?
        halt 400, { error: 'Missing or invalid "ptos" array' }.to_json unless data['ptos'].is_a?(Array)
      rescue StandardError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end

      # Write to storage
      begin
        shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)
        shared_storage.write(success: { ptos: data['ptos'] })
      rescue StandardError => e
        halt 500, { error: 'Internal Server Error' }.to_json
      end

      status 200
      { message: 'PTOs stored successfully' }.to_json
    end
  end
end
