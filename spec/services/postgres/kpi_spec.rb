# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/kpi'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Kpi do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  before(:each) do
    db.drop_table?(:kpis)
    db.drop_table?(:domains)

    create_kpis_table(db)
    create_domains_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new kpi and returns its ID' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      params = {
        external_kpi_id: 'ext-kpi-1',
        description: 'First KPI',
        domain_id: domain_id
      }
      id = service.insert(params)
      kpi = service.find(id)
      expect(kpi[:description]).to eq('First KPI')
      expect(kpi[:external_kpi_id]).to eq('ext-kpi-1')
    end

    it 'assigns domain_id when given external_domain_id' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      params = {
        external_kpi_id: 'ext-kpi-2',
        description: 'KPI with Domain',
        external_domain_id: 'dom-1'
      }
      id = service.insert(params)
      kpi = service.find(id)
      expect(kpi[:domain_id]).to eq(domain_id)
    end
  end

  describe '#update' do
    it 'updates a kpi by ID' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      id = service.insert(external_kpi_id: 'ext-kpi-4', description: 'Old Description', domain_id: domain_id)
      service.update(id, { description: 'Updated Description' })
      updated = service.find(id)
      expect(updated[:description]).to eq('Updated Description')
      expect(updated[:external_kpi_id]).to eq('ext-kpi-4')
    end

    it 'reassigns domain_id on update with external_domain_id' do
      domain1_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      domain2_id = domain_service.insert(external_domain_id: 'dom-2', name: 'Domain2')
      id = service.insert(
        external_kpi_id: 'ext-kpi-5',
        description: 'To Update Domain',
        domain_id: domain1_id
      )
      service.update(id, { external_domain_id: 'dom-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain2_id)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, description: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a kpi by ID' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      id = service.insert(external_kpi_id: 'ext-kpi-6', description: 'To Delete', domain_id: domain_id)
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a kpi by ID' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      id = service.insert(external_kpi_id: 'ext-kpi-7', description: 'Find Me', domain_id: domain_id)
      found = service.find(id)
      expect(found[:description]).to eq('Find Me')
      expect(found[:external_kpi_id]).to eq('ext-kpi-7')
    end
  end

  describe '#query' do
    it 'queries kpis by condition' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      id = service.insert(external_kpi_id: 'ext-kpi-8', description: 'Query Me', domain_id: domain_id)
      results = service.query(description: 'Query Me')
      expect(results.map { |k| k[:id] }).to include(id)
      expect(results.first[:external_kpi_id]).to eq('ext-kpi-8')
    end

    it 'returns all kpis with empty conditions' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      count = service.query.size
      service.insert(external_kpi_id: 'ext-kpi-9', description: 'Another', domain_id: domain_id)
      expect(service.query.size).to eq(count + 1)
    end
  end
end
