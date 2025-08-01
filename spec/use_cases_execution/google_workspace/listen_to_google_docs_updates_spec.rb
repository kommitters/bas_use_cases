# frozen_string_literal: true

require 'spec_helper'
require_relative 'env_helper'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/use_cases_execution/warehouse/google_workspace/listen_to_google_docs_updates'

RSpec.describe Routes::GoogleDocuments do
  include Rack::Test::Methods

  def app
    described_class.new({})
  end

  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }

  let(:valid_payload) do
    {
      'google_documents' => [
        {
          'external_document_id' => 'document_id_1',
          'name' => 'Document Title 1',
          'external_domain_id' => 'domain_id_1'
        },
        {
          'external_document_id' => 'document_id_2',
          'name' => 'Document Title 2',
          'external_domain_id' => 'domain_id_2'
        }
      ]
    }
  end

  def post_google_docs(payload)
    post '/google_docs', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_shared_storage_writer)
    allow(mocked_shared_storage_writer).to receive(:write).and_return(true)
    allow_any_instance_of(Routes::GoogleDocuments).to receive(:logger).and_return(double('logger').as_null_object)
  end

  context 'POST /google_docs' do
    it 'returns 400 for empty request body' do
      post '/google_docs', '', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      post '/google_docs', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing google_documents key' do
      post_google_docs({ 'wrong_key' => [] })

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "google_documents" array')
    end

    it 'returns 400 if google_documents is not an array' do
      post_google_docs({ 'google_documents' => 'not an array' })

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "google_documents" array')
    end

    it 'returns 200 and success message when valid google_documents are sent' do
      post_google_docs(valid_payload)

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'Google documents stored successfully')
    end

    it 'returns 500 if shared storage write fails' do
      allow(mocked_shared_storage_writer).to receive(:write).and_raise(StandardError.new('boom'))

      post_google_docs(valid_payload)

      expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error')
      expect(last_response.status).to eq(500)
    end
  end
end
