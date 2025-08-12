# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/kpi_history'
require_relative '../../../src/services/postgres/kpi'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::KpiHistory do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:kpi_service) { Services::Postgres::Kpi.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  let(:valid_params) do
    {
      kpi_id: @kpi_id,
      domain_id: @domain_id,
      description: 'Initial KPI state',
      status: 'On Track',
      current_value: 10.0
    }
  end

  before(:each) do
    db.drop_table?(:kpis_history)
    db.drop_table?(:kpis)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_kpis_table(db)
    create_kpis_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    @domain_id = domain_service.insert(name: 'Test Domain', external_domain_id: 'ext-dom-1')
    @kpi_id = kpi_service.insert(
      external_kpi_id: 'ext-kpi-1',
      domain_id: @domain_id,
      description: 'A KPI to be historized'
    )
  end

  describe '#insert' do
    it 'creates a new kpi history record and returns its ID' do
      id = service.insert(valid_params)
      result = service.find(id)

      expect(result).not_to be_nil
      expect(result[:kpi_id]).to eq(@kpi_id)
      expect(result[:description]).to eq('Initial KPI state')
    end
  end

  describe '#update' do
    let!(:history_id) { service.insert(valid_params) }

    it 'updates the kpi history record' do
      service.update(history_id, description: 'Updated KPI state')
      updated_record = service.find(history_id)

      expect(updated_record[:description]).to eq('Updated KPI state')
    end

    it 'raises an ArgumentError if the id is null' do
      expect { service.update(nil, {}) }.to raise_error(ArgumentError, 'KpiHistory id is required to update')
    end
  end

  describe '#delete' do
    it 'removes a kpi history record by its ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.count }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a kpi history record by its ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:id]).to eq(id)
      expect(found[:description]).to eq('Initial KPI state')
    end
  end

  describe '#query' do
    it 'returns records based on a filter' do
      service.insert(valid_params)
      service.insert(valid_params.merge(description: 'Another state'))

      results = service.query(kpi_id: @kpi_id)
      expect(results.count).to eq(2)
      expect(results.first[:description]).to eq('Initial KPI state')
    end

    it 'returns all history records if conditions are empty' do
      service.insert(valid_params)
      expect(service.query.size).to eq(1)
    end
  end
end
