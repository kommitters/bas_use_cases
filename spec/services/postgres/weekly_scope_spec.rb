# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/weekly_scope'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::WeeklyScope do
  include TestDBHelpers

  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:start_week_date) { Date.new(2024, 6, 13) }
  let(:end_week_date) { Date.new(2024, 6, 19) }
  let(:params) do
    { external_weekly_scope_id: 'ws-1', description: 'engineering-week-1', start_week_date:, end_week_date: }
  end

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:weekly_scopes_history)
    db.drop_table?(:weekly_scopes)

    create_weekly_scopes_table(db)
    create_weekly_scopes_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new weekly scope and returns its ID' do
      id = service.insert(params)
      weekly_scope = service.find(id)

      expect(weekly_scope[:external_weekly_scope_id]).to eq('ws-1')
      expect(weekly_scope[:description]).to eq('engineering-week-1')
      expect(weekly_scope[:start_week_date]).to eq(start_week_date.to_time)
      expect(weekly_scope[:end_week_date]).to eq(end_week_date.to_time)
    end
  end

  describe '#update' do
    it 'updates an weekly scope by ID' do
      id = service.insert(params)
      service.update(id, { description: 'Updated Description' })
      updated = service.find(id)

      expect(updated[:external_weekly_scope_id]).to eq('ws-1')
      expect(updated[:description]).to eq('Updated Description')
      expect(updated[:start_week_date]).to eq(start_week_date.to_time)
      expect(updated[:end_week_date]).to eq(end_week_date.to_time)
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(
        external_weekly_scope_id: 'ws-hist-1',
        description: 'Initial Draft',
        start_week_date: start_week_date
      )

      expect(db[:weekly_scopes_history].where(weekly_scope_id: id).all).to be_empty

      service.update(id, { description: 'Final Version' })

      updated_record = service.find(id)
      expect(updated_record[:description]).to eq('Final Version')

      history_records = db[:weekly_scopes_history].where(weekly_scope_id: id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:weekly_scope_id]).to eq(id)
      expect(historical_record[:description]).to eq('Initial Draft')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(description: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a weekly scope by ID' do
      id = service.insert(params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a weekly scope by ID' do
      id = service.insert(params)
      found = service.find(id)

      expect(found[:external_weekly_scope_id]).to eq('ws-1')
      expect(found[:description]).to eq('engineering-week-1')
      expect(found[:start_week_date]).to eq(start_week_date.to_time)
      expect(found[:end_week_date]).to eq(end_week_date.to_time)
    end
  end

  describe '#query' do
    it 'queries weekly scope by condition' do
      id = service.insert(params)
      results = service.query(external_weekly_scope_id: 'ws-1')

      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_weekly_scope_id]).to eq('ws-1')
    end

    it 'returns all weekly scope with empty conditions' do
      count = service.query.size
      service.insert(params)

      expect(service.query.size).to eq(count + 1)
    end
  end
end
