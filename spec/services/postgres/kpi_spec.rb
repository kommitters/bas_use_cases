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
  let(:domain_id) { domain_service.insert(name: 'Test Domain', external_domain_id: 'ext-dom-1') }

  let(:history_service) { Services::Postgres::HistoryService.new(config, :kpis_history, :kpi_id) }

  let(:valid_params) do
    {
      external_kpi_id: 'ext-kpi-1',
      domain_id: domain_id,
      description: 'Track user engagement',
      status: 'On Track',
      current_value: 50.0,
      percentage: 0.5,
      target_value: 100.0,
      stats: { trend: 'up' }.to_json
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
  end

  describe '#insert' do
    it 'creates a new kpi record and returns its ID' do
      id = service.insert(valid_params)
      result = service.find(id)

      expect(result).not_to be_nil
      expect(result[:description]).to eq('Track user engagement')
    end
  end

  describe '#update' do
    let!(:id) { service.insert(valid_params) }

    it 'updates the kpi record' do
      service.update(id, description: 'Updated KPI state')
      expect(service.find(id)[:description]).to eq('Updated KPI state')
    end

    it 'saves the correct previous state to the history table before updating' do
      initial_kpi = service.find(id)
      expect(initial_kpi[:status]).to eq('On Track')
      expect(initial_kpi[:current_value]).to eq(50.0)

      expect(history_service.query(kpi_id: id)).to be_empty

      service.update(id, { status: 'At Risk', current_value: 55.0 })

      updated_kpi = service.find(id)
      expect(updated_kpi[:status]).to eq('At Risk')
      expect(updated_kpi[:current_value]).to eq(55.0)

      history_records = history_service.query(kpi_id: id)
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:kpi_id]).to eq(id)
      expect(historical_record[:status]).to eq('On Track')
      expect(historical_record[:current_value]).to eq(50.0)
    end

    it 'raises an ArgumentError if the id is null' do
      expect do
        service.update(nil, {})
      end.to raise_error(ArgumentError, 'KPI id is required to update')
    end
  end

  describe '#delete' do
    it 'removes a kpi by its ID' do
      id = service.insert(valid_params)
      expect { service.delete(id) }.to change { service.query.count }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a kpi by its ID' do
      id = service.insert(valid_params)
      found = service.find(id)
      expect(found[:id]).to eq(id)
    end
  end

  describe '#query' do
    it 'returns records based on a filter' do
      id = service.insert(valid_params)
      results = service.query(status: 'On Track')
      expect(results.first[:id]).to eq(id)
    end

    it 'returns all kpi records if conditions are empty' do
      service.insert(valid_params)
      service.insert(valid_params.merge(external_kpi_id: 'ext-kpi-2'))
      expect(service.query.size).to eq(2)
    end
  end
end
