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

  let(:valid_payload) do
    {
      name: 'Ana',
      email: 'ana@example.com',
      thematic: ['Emergency response'],
      feature: 'contact_form'
    }.to_json
  end

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
      it 'responds with 200 OK for valid JSON payload' do
        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end

      it 'initializes storage with correct options' do
        expect(Bas::SharedStorage::Postgres).to receive(:new)
          .with(write_options: write_options)
          .and_return(double(write: true))

        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'writes the parsed JSON data to storage' do
        mock_storage = double
        expect(Bas::SharedStorage::Postgres).to receive(:new).and_return(mock_storage)
        expect(mock_storage).to receive(:write).with(success: JSON.parse(valid_payload))

        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
      end
    end

    context 'with invalid requests' do
      it 'raises JSON::ParserError for malformed JSON' do
        expect do
          post '/webhook', '{invalid: json}', { 'CONTENT_TYPE' => 'application/json' }
        end.to raise_error(JSON::ParserError)
      end

      it 'raises JSON::ParserError for empty body' do
        expect do
          post '/webhook', '', { 'CONTENT_TYPE' => 'application/json' }
        end.to raise_error(JSON::ParserError)
      end

      it 'accepts non-JSON content type if body is valid JSON' do
        post '/webhook', valid_payload, { 'CONTENT_TYPE' => 'text/plain' }
        expect(last_response.status).to eq(200)
      end
    end
  end
end
