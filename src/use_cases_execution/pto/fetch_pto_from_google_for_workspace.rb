# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'time'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../../src/implementations/fetch_pto_from_google'

set :server, :puma
set :bind, '0.0.0.0'
set :environment, Config::RACK_ENV

write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromGoogleWorkspace'
}

shared_storage_reader = Bas::SharedStorage::Default.new
shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)

post '/pto' do
  begin
    request_body = request.body.read.to_s

    if request_body.strip.empty?
      status 400
      return { error: 'Empty request body' }.to_json
    end

    data = JSON.parse(request_body)
    ptos = data['ptos']

    unless ptos.is_a?(Array)
      status 400
      return { error: 'Missing or invalid "ptos" array' }.to_json
    end

    bot = Implementation::FetchPtoFromGoogle.new({ ptos: ptos }, shared_storage_reader, shared_storage_writer)
    result = bot.execute

    status 200
    result.to_json

  rescue JSON::ParserError => e
    logger.error "Invalid JSON format: #{e.message}"
    status 400
    { error: 'Invalid JSON format' }.to_json

  rescue StandardError => e
    logger.error "Failed to process PTO data: #{e.message}"
    status 500
    { error: 'Internal Server Error' }.to_json
  end
end
