# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

module Routes
  # Routes::Birthdays handles incoming birthday data from Google Workspace
  #
  # POST /birthday - Accepts JSON payload with birthday data
  # Expected format: { "birthdays": [array of birthday objects] }
  # Returns: 200 with success message or 400/500 with error details
  class Birthdays < Sinatra::Base
    write_options = {
      connection: Config::CONNECTION,
      db_table: 'birthday',
      tag: 'FetchBirthdaysFromGoogle'
    }.freeze

    post '/birthday' do
      content_type :json

      begin
        request_body = request.body.read
        halt 400, { error: 'Empty request body' }.to_json if request_body.strip.empty?

        data = JSON.parse(request_body)
        halt 400, { error: 'Invalid JSON format' }.to_json unless data.is_a?(Hash) && !data.empty?
        halt 400, { error: 'Missing or invalid "birthdays" array' }.to_json unless data['birthdays'].is_a?(Array)
      rescue StandardError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end

      begin
        shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)
        shared_storage.write(success: data)
      rescue StandardError
        halt 500, { error: 'Internal Server Error' }.to_json
      end
      status 200
      { message: 'Birthdays stored successfully' }.to_json
    end
  end
end
