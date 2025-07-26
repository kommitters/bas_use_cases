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
  let(:formatted_ptos) do
    [
      'Jane Doe will not be working between 2025-07-23 and 2025-07-25. And returns the Monday, July 28, 2025',
      'John Johnson will not be working between 2025-07-20 and 2025-07-26. And returns the Monday, July 28, 2025'
    ]
  end

  def post_pto(ptos)
    post '/pto', ptos.to_json, { 'CONTENT_TYPE' => 'application/json' }
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
  end
end
