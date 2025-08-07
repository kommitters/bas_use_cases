# frozen_string_literal: true

require 'spec_helper'
require_relative 'env_helper'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/use_cases_execution/warehouse/google_workspace/listen_to_google_docs_activity_logs'

RSpec.describe Routes::GoogleDocumentsActivityLogs do
  include Rack::Test::Methods

  def app
    described_class.new({})
  end

  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:token) { 'test_token' }

  let(:valid_payload) do
    {
      'google_docs_activity_logs' => [
        {
          'external_document_id' => 'document_id_1',
          'name' => 'Document Title 1',
          'external_domain_id' => 'domain_id_1',
          "action": 'edit',
          "details": {
            "title": 'Document Title 1',
            "content": 'Document Content 1'
          },
          "person_id": 'person_id_1',
          "timestamp": '2025-08-01T19:50:24.720Z',
          "email_address": 'example@example.com',
          "unique_identifier": '1A_doc_1-2025-08-01T19:50:24.720Z'
        },
        {
          'external_document_id' => 'document_id_2',
          'name' => 'Document Title 2',
          'external_domain_id' => 'domain_id_2',
          "action": 'edit',
          "details": {
            "title": 'Document Title 2',
            "content": 'Document Content 2'
          },
          "person_id": 'person_id_2',
          "timestamp": '2025-08-01T19:50:24.720Z',
          "email_address": 'exampl2@example.com',
          "unique_identifier": '1A_doc_1-2025-08-01T19:57:24.720Z'
        }
      ]
    }
  end

  def post_google_docs_activity_logs(payload, token)
    header 'Authorization', "Bearer #{token}"
    post '/google_docs_activity_logs', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_shared_storage_writer)
    allow(mocked_shared_storage_writer).to receive(:write).and_return(true)
    allow_any_instance_of(Routes::GoogleDocumentsActivityLogs).to(
      receive(:logger).and_return(double('logger').as_null_object)
    )
    stub_const('ENV', ENV.to_h.merge('WEBHOOK_TOKEN' => token))
  end

  context 'POST /google_docs_activity_logs' do
    it 'returns 401 for missing authorization header' do
      post '/google_docs_activity_logs', valid_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(401)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid Authorization header')
    end

    it 'returns 403 for invalid token' do
      post_google_docs_activity_logs(valid_payload, 'invalid_token')

      expect(last_response.status).to eq(403)
      expect(JSON.parse(last_response.body)).to include('error' => 'Forbidden: invalid token')
    end

    it 'returns 400 for empty request body' do
      header 'Authorization', "Bearer #{token}"
      post '/google_docs_activity_logs', '', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      header 'Authorization', "Bearer #{token}"
      post '/google_docs_activity_logs', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing google_docs_activity_logs key' do
      post_google_docs_activity_logs({ 'wrong_key' => [] }, token)

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to(
        include('error' => 'Missing or invalid "google_docs_activity_logs" array')
      )
    end

    it 'returns 400 if google_docs_activity_logs is not an array' do
      post_google_docs_activity_logs({ 'google_docs_activity_logs' => 'not an array' }, token)

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to(
        include('error' => 'Missing or invalid "google_docs_activity_logs" array')
      )
    end

    it 'returns 200 and success message when valid google_docs_activity_logs are sent' do
      post_google_docs_activity_logs(valid_payload, token)

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to(
        include('message' => 'Google documents activity logs stored successfully')
      )
    end

    it 'returns 500 if shared storage write fails' do
      allow(mocked_shared_storage_writer).to receive(:write).and_raise(StandardError.new('boom'))

      post_google_docs_activity_logs(valid_payload, token)

      expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error')
      expect(last_response.status).to eq(500)
    end
  end
end
