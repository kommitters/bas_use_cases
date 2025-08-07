# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/document_activity_log'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::DocumentActivityLog do
  include TestDBHelpers

  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }
  let(:document_service) { Services::Postgres::Document.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:document_activity_logs)
    db.drop_table?(:documents)
    db.drop_table?(:persons)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_documents_table(db)
    create_persons_table(db)
    create_document_activity_logs_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  let(:domain_id) do
    domain_service.insert(external_domain_id: 'test-domain', name: 'Test Domain')
  end

  let(:document_id) do
    document_service.insert(external_document_id: 'ext-doc-1', name: 'ops-doc',
                            external_domain_id: domain_id)
  end
  let(:person_id) do
    person_service.insert(external_person_id: 'person-1', full_name: 'John Doe',
                          email_address: 'john@example.com', external_domain_id: domain_id)
  end

  describe '#insert' do
    it 'creates a new document activity log and returns its ID and assigns foreign keys' do
      params = { document_id: document_id, person_id: person_id, action: 'create',
                 details: { date: '2025-01-01' } }
      id = service.insert(params)
      document_activity_log = service.find(id)
      expect(document_activity_log[:document_id]).to eq(document_id)
      expect(document_activity_log[:person_id]).to eq(person_id)
      expect(document_activity_log[:action]).to eq('create')
      expect(JSON.parse(document_activity_log[:details])).to eq({ 'date' => '2025-01-01' })
    end

    it 'does not assign person_id if it is not provided' do
      params = { document_id: document_id, action: 'create', details: { date: '2025-01-01' } }
      id = service.insert(params)
      document_activity_log = service.find(id)
      expect(document_activity_log[:document_id]).to eq(document_id)
      expect(document_activity_log[:person_id]).to be_nil
    end
  end

  describe '#update' do
    it 'updates a document activity log by ID' do
      id = service.insert(document_id: document_id, person_id: person_id, action: 'create',
                          details: { date: '2025-01-01' })
      service.update(id, { action: 'update', details: { date: '2025-01-02' } })
      document_activity_log = service.find(id)
      expect(document_activity_log[:action]).to eq('update')
      expect(JSON.parse(document_activity_log[:details])).to eq({ 'date' => '2025-01-02' })
    end

    it 'reassigns person_id on update with external_person_id' do
      person_id2 = person_service.insert(external_person_id: 'person-2', full_name: 'Jane Doe',
                                         email_address: 'jane@example.com', external_domain_id: domain_id)
      id = service.insert(document_id: document_id, person_id: person_id, action: 'create',
                          details: { date: '2025-01-01' })
      service.update(id, { person_id: person_id2 })
      updated_document_activity_log = service.find(id)
      expect(updated_document_activity_log[:person_id]).to eq(person_id2)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a document activity log by ID' do
      id = service.insert(document_id: document_id, person_id: person_id, action: 'create',
                          details: { date: '2025-01-01' })
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a document activity log by ID' do
      id = service.insert(document_id: document_id, person_id: person_id, action: 'create',
                          details: { date: '2025-01-01' })
      document_activity_log = service.find(id)
      expect(document_activity_log[:id]).to eq(id)
      expect(document_activity_log[:document_id]).to eq(document_id)
      expect(document_activity_log[:person_id]).to eq(person_id)
      expect(document_activity_log[:action]).to eq('create')
      expect(JSON.parse(document_activity_log[:details])).to eq({ 'date' => '2025-01-01' })
    end
  end

  describe '#query' do
    let!(:record_1_id) do
      service.insert(document_id: document_id, person_id: person_id, action: 'create',
                     details: '{"date": "2025-01-01"}')
    end

    let!(:record_2_id) do
      service.insert(document_id: document_id, person_id: person_id, action: 'update',
                     details: '{"date": "2025-01-02"}')
    end

    it 'queries document activity logs by condition' do
      results = service.query(action: 'create')
      expect(results.map { |a| a[:id] }).to include(record_1_id)
      expect(results.map { |a| a[:id] }).not_to include(record_2_id)
    end

    it 'returns all document activity logs with empty conditions' do
      expect(service.query.size).to eq(2)
      expect(service.query.map { |a| a[:id] }).to match_array([record_1_id, record_2_id])
    end
  end
end
