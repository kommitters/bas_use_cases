# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/document'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Document do
  include TestDBHelpers

  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  let(:history_service) { Services::Postgres::HistoryService.new(config, :documents_history, :document_id) }

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:documents_history)
    db.drop_table?(:documents)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_documents_table(db)
    create_documents_history_table(db)

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

    it 'assigns domain_id when given external_domain_id' do
      domain_id = domain_service.insert(external_domain_id: 'ext-d-1', name: 'Domain1')
      params = {
        external_document_id: 'ext-d-2',
        name: 'With Domain',
        external_domain_id: 'ext-d-1'
      }
      id = service.insert(params)
      document = service.find(id)
      expect(document[:domain_id]).to eq(domain_id)
    end

    it 'removes external_domain_id if it is present and nil' do
      params = {
        external_document_id: 'ext-d-3',
        name: 'Nil Domain',
        external_domain_id: nil
      }
      id = service.insert(params)
      document = service.find(id)
      expect(document).not_to have_key(:external_domain_id)
      expect(document[:domain_id]).to be_nil
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

    it 'reassigns domain_id on update with external_domain_id' do
      domain = domain_service.insert(external_domain_id: 'domain-2', name: 'Domain2')
      id = service.insert(external_document_id: 'ext-a-5', name: 'To Reassign', external_domain_id: 'domain-1')
      service.update(id, { external_domain_id: 'domain-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain)
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(external_document_id: 'doc-hist-1', name: 'Initial Version')

      expect(history_service.query(document_id: id)).to be_empty

      service.update(id, { name: 'Updated Version' })

      updated_record = service.find(id)
      expect(updated_record[:name]).to eq('Updated Version')

      history_records = history_service.query(document_id: id)
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:document_id]).to eq(id)
      expect(historical_record[:name]).to eq('Initial Version')
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
