# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../../src/implementations/fetch_birthdays_from_google'

module Routes
  # Routes::Birthdays defines the /birthday endpoint that receives birthday data
  class Birthdays < Sinatra::Base
    write_options = {
      connection: Config::CONNECTION,
      db_table: 'birthday',
      tag: 'FetchBirthdaysFromGoogle'
    }

    shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)

    post '/birthday' do
      request_body = request.body.read.to_s

      if request_body.strip.empty?
        status 400
        return { error: 'Empty request body' }.to_json
      end

      data = JSON.parse(request_body)
      birthdays = data['birthdays']

      unless birthdays.is_a?(Array)
        status 400
        return { error: 'Missing or invalid "birthdays" array' }.to_json
      end

      shared_storage_writer.write(success: data) unless data.nil?

      status 200
      { success: true }.to_json
    rescue JSON::ParserError => e
      logger.error "Invalid JSON format: #{e.message}"
      status 400
      { error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      logger.error "Failed to process birthdays: #{e.message}"
      status 500
      { error: 'Internal Server Error' }.to_json
    end
  end
end
