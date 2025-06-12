# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/document'

RSpec.describe Services::Postgres::Document do
  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:documents)
    db.create_table(:documents) do
      primary_key :id
      String :name, null: false
      String :external_document_id, null: false
      DateTime :created_at
      DateTime :updated_at
    end
    # Inject the in-memory DB connection into the service
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new document and returns its ID' do
      params = { external_document_id: 'ext-doc-1', name: 'ops-doc' }
      id = service.insert(params)
      document = service.find(id)
      expect(document[:name]).to eq('ops-doc')
      expect(document[:external_document_id]).to eq('ext-doc-1')
    end
  end

  describe '#update' do
    it 'updates an document by ID' do
      id = service.insert(external_document_id: 'ext-doc-2', name: 'To Update')
      service.update(id, { name: 'Updated Document' })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Document')
      expect(updated[:external_document_id]).to eq('ext-doc-2')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a document by ID' do
      id = service.insert(external_document_id: 'ext-doc-3', name: 'To Delete')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a document by ID' do
      id = service.insert(external_document_id: 'ext-doc-4', name: 'Find Me')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_document_id]).to eq('ext-doc-4')
    end
  end

  describe '#query' do
    it 'queries documents by condition' do
      id = service.insert(external_document_id: 'ext-doc-5', name: 'Query Me')
      results = service.query(name: 'Query Me')
      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_document_id]).to eq('ext-doc-5')
    end

    it 'returns all documents with empty conditions' do
      count = service.query.size
      service.insert(external_document_id: 'ext-doc-6', name: 'Another')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
