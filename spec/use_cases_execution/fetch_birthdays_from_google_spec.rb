# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'json'
require 'sinatra/base'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

# Define a mock Config module
module Config
  CONNECTION = { mocked: true }.freeze
end

require_relative '../../src/use_cases_execution/birthday/fetch_birthdays_from_google'

RSpec.describe Routes::Birthdays do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }

  let(:valid_payload) do
    {
      birthdays: [
        { name: 'Test', birthday_date: '2025-07-25' },
        { name: 'Test2', birthday_date: '2025-07-26' }
      ]
    }
  end

  def post_birthday(payload)
    post '/birthday', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_shared_storage_writer)
    allow(mocked_shared_storage_writer).to receive(:write).and_return(true)
    allow_any_instance_of(Routes::Birthdays).to receive(:logger).and_return(double('logger').as_null_object)
  end

  describe 'POST /birthday' do
    context 'when the request is malformed, incomplete, or causes storage errors' do
      it 'returns 400 for empty request body' do
        post '/birthday', '', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
      end

      it 'returns 400 for invalid JSON' do
        post '/birthday', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
      end

      it 'returns 400 for missing birthdays key' do
        post_birthday({ something_else: [] })

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "birthdays" array')
      end

      it 'returns 400 if birthdays is not an array' do
        post_birthday({ birthdays: 'not-an-array' })

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "birthdays" array')
      end

      it 'returns 500 if shared storage write fails' do
        allow(mocked_shared_storage_writer).to receive(:write).and_raise(StandardError.new('boom'))

        post_birthday(valid_payload)

        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error')
      end
    end

    context 'when the request contains valid birthday data and storage succeeds' do
      it 'returns 200 and success message for valid birthday data' do
        post_birthday(valid_payload)

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to include('message' => 'Birthdays stored successfully')
      end
    end
  end
end
