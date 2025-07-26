# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

# Define a mock Config module and CONNECTION constant
module Config
  CONNECTION = { mocked: true }.freeze
end

require_relative '../../../src/use_cases_execution/birthday/fetch_birthdays_from_google'

RSpec.describe Routes::Birthdays do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_default) { instance_double(Bas::SharedStorage::Default) }

  before do
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_shared_storage_writer)
    allow(mocked_shared_storage_writer).to receive(:write).with(hash_including(success: anything)).and_return(true)

    allow(Bas::SharedStorage::Default).to receive(:new).and_return(mocked_shared_storage_default)

    allow_any_instance_of(Routes::Birthdays).to receive(:logger).and_return(double('logger').as_null_object)
  end

  let(:valid_payload) do
    {
      birthdays: [
        { name: 'Test', birthday_date: '2025-07-25' },
        { name: 'Test2', birthday_date: '2025-07-25' }
      ]
    }.to_json
  end

  it 'returns 200 and saves valid birthday data to shared storage' do
    post '/birthday', valid_payload, { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq({ 'success' => true })
  end

  it 'validates format of each birthday item' do
    payload = {
      birthdays: [
        { name: 'Ana', birthday_date: '2025-12-10' },
        { name: 'Luis', birthday_date: '2025-08-15' }
      ]
    }

    post '/birthday', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

    body = JSON.parse(last_response.body)
    expect(last_response.status).to eq(200)
    expect(body['success']).to be true
  end

  it 'returns 400 if request body is empty' do
    post '/birthday', '', { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Empty request body' })
  end

  it 'returns 400 if JSON is malformed' do
    post '/birthday', '{ invalid_json }', { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Invalid JSON format' })
  end

  it 'returns 400 if birthdays key is missing' do
    payload = { something_else: [] }.to_json

    post '/birthday', payload, { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Missing or invalid "birthdays" array' })
  end

  it 'returns 400 if birthdays is not an array' do
    payload = { birthdays: 'not-an-array' }.to_json

    post '/birthday', payload, { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq({ 'error' => 'Missing or invalid "birthdays" array' })
  end
end
