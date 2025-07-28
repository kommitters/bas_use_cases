# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'spec_helper'
require 'rack/test'
require_relative '../../../src/use_cases_execution/website_contact_form/form_submissions_webhook'

describe Routes::FormSubmissions do
  include Rack::Test::Methods

  def app
    Routes::FormSubmissions.new
  end

  let(:valid_payload_hash) do
    {
      name: 'Ana',
      email: 'ana@example.com',
      thematic: ['Emergency response'],
      feature: 'contact_form'
    }
  end

  let(:valid_payload) { valid_payload_hash.to_json }

  let(:write_options) do
    {
      connection: Config::CONNECTION,
      db_table: 'website_form_contact',
      tag: 'WebsiteContactForm'
    }
  end

  before do
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(double(write: true))
  end

  describe 'POST /webhook' do
    context 'with valid requests' do
      it 'responds with 200 OK and success message' do
        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq('message' => 'Form submission received successfully')
      end

      it 'initializes storage with correct options' do
        expect(Bas::SharedStorage::Postgres).to receive(:new)
          .with(write_options: write_options)
          .and_return(double(write: true))

        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'writes the parsed JSON data to storage' do
        parsed_payload = JSON.parse(valid_payload)

        mock_storage = double
        allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mock_storage)

        expect(mock_storage).to receive(:write).with(success: parsed_payload)

        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
      end
    end

    context 'with invalid requests' do
      it 'returns 400 for malformed JSON' do
        post '/webhook', '{invalid: json}', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid JSON format')
      end

      it 'returns 400 for empty body' do
        post '/webhook', '', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq('error' => 'Empty request body')
      end

      it 'returns 400 for empty JSON object' do
        post '/webhook', '{}', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid JSON format')
      end

      it 'returns 400 for non-object JSON (like array)' do
        post '/webhook', '[1,2,3]', { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid JSON format')
      end
    end
  end
end
