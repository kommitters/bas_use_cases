# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'json'
require 'sinatra/base'
require_relative '../../../src/use_cases_execution/pto/fetch_pto_from_google_for_workspace'

RSpec.describe Routes::Pto do
  include Rack::Test::Methods

  let(:app) { described_class.new }

  let(:valid_payload) do
    {
      ptos: [
        { name: 'Jane Doe', start_date: '2025-07-23', end_date: '2025-07-25' },
        { name: 'John Johnson', start_date: '2025-07-20', end_date: '2025-07-26' }
      ]
    }
  end

  def post_pto(payload)
    post '/pto', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    # Stub el escritor para evitar conexión real a base de datos
    allow_any_instance_of(Bas::SharedStorage::Postgres)
      .to receive(:write)
      .and_return(true)
  end

  context 'POST /pto' do
    it 'returns 400 for empty request body' do
      post '/pto', '', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      post '/pto', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing ptos key' do
      post_pto({ wrong_key: [] })

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "ptos" array')
    end

    it 'returns 400 if ptos is not an array' do
      post_pto({ ptos: 'not an array' })

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "ptos" array')
    end

    it 'returns 200 and success message when valid ptos are sent' do
      post_pto(valid_payload)

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'PTOs stored successfully')
    end
  end
end
