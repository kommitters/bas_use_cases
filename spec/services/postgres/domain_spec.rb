# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Domain do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }

  before(:each) do
    db.drop_table?(:domains_history)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_domains_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new domain and returns its ID' do
      params = {
        external_domain_id: 'ext-d-1',
        name: 'Domain One',
        archived: false
      }
      id = service.insert(params)
      domain = service.find(id)
      expect(domain[:name]).to eq('Domain One')
      expect(domain[:external_domain_id]).to eq('ext-d-1')
      expect(domain[:archived]).to eq(false)
    end
  end

  describe '#update' do
    it 'updates a domain by ID' do
      id = service.insert(external_domain_id: 'ext-d-2', name: 'Old Name', archived: false)
      service.update(id, { name: 'Updated Name', archived: true })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Name')
      expect(updated[:archived]).to eq(true)
      expect(updated[:external_domain_id]).to eq('ext-d-2')
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(external_domain_id: 'd-hist-1', name: 'Initial State', archived: false)

      expect(db[:domains_history].where(domain_id: id).all).to be_empty

      service.update(id, { name: 'Updated State', archived: true })

      updated_record = service.find(id)
      expect(updated_record[:name]).to eq('Updated State')
      expect(updated_record[:archived]).to be true

      history_records = db[:domains_history].where(domain_id: id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:domain_id]).to eq(id)
      expect(historical_record[:name]).to eq('Initial State')
      expect(historical_record[:archived]).to be false
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a domain by ID' do
      id = service.insert(external_domain_id: 'ext-d-3', name: 'To Delete', archived: false)
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a domain by ID' do
      id = service.insert(external_domain_id: 'ext-d-4', name: 'Find Me', archived: false)
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_domain_id]).to eq('ext-d-4')
      expect(found[:archived]).to eq(false)
    end
  end

  describe '#query' do
    it 'queries domains by condition' do
      id = service.insert(external_domain_id: 'ext-d-5', name: 'Query Me', archived: false)
      results = service.query(name: 'Query Me')
      expect(results.map { |d| d[:id] }).to include(id)
      expect(results.first[:external_domain_id]).to eq('ext-d-5')
    end

    it 'returns all domains with empty conditions' do
      count = service.query.size
      service.insert(external_domain_id: 'ext-d-6', name: 'Another', archived: false)
      expect(service.query.size).to eq(count + 1)
    end
  end
end
