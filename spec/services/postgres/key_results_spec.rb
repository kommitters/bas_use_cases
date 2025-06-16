# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/key_results'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::KeyResults do
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
  let(:params) do
    {
      external_key_result_id: 'ad3dcdfc-24e9-4008-a026-0e7958655aa9', okr: 'save time', key_result: 'save time result',
      metric: 12, current: 56, progress: 84, period: 'Q2', objective: 'save a lot of time'
    }
  end

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:key_results)
    db.drop_table?(:key_results_history)

    create_key_results_table(db)
    create_key_results_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new key result history and returns its ID' do
      id = service.insert(params)
      key_result = service.find(id)

      expect(key_result[:external_key_result_id]).to eq('ad3dcdfc-24e9-4008-a026-0e7958655aa9')
      expect(key_result[:okr]).to eq('save time')
      expect(key_result[:key_result]).to eq('save time result')
      expect(key_result[:metric]).to eq(12)
      expect(key_result[:current]).to eq(56)
      expect(key_result[:progress]).to eq(84)
      expect(key_result[:period]).to eq('Q2')
      expect(key_result[:objective]).to eq('save a lot of time')
    end
  end

  describe '#update' do
    it 'updates an key result history by ID' do
      id = service.insert(params)
      service.update(id, { key_result: 'Updated Key Result' })
      updated = service.find(id)

      expect(updated[:external_key_result_id]).to eq('ad3dcdfc-24e9-4008-a026-0e7958655aa9')
      expect(updated[:okr]).to eq('save time')
      expect(updated[:key_result]).to eq('Updated Key Result')
      expect(updated[:metric]).to eq(12)
      expect(updated[:current]).to eq(56)
      expect(updated[:progress]).to eq(84)
      expect(updated[:period]).to eq('Q2')
      expect(updated[:objective]).to eq('save a lot of time')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(key_result: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a key_result by ID' do
      id = service.insert(params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a key result by ID' do
      id = service.insert(params)
      found = service.find(id)

      expect(found[:external_key_result_id]).to eq('ad3dcdfc-24e9-4008-a026-0e7958655aa9')
      expect(found[:okr]).to eq('save time')
      expect(found[:key_result]).to eq('save time result')
      expect(found[:metric]).to eq(12)
      expect(found[:current]).to eq(56)
      expect(found[:progress]).to eq(84)
      expect(found[:period]).to eq('Q2')
      expect(found[:objective]).to eq('save a lot of time')
    end
  end

  describe '#query' do
    it 'queries key result by condition' do
      id = service.insert(params)
      results = service.query(external_key_result_id: 'ad3dcdfc-24e9-4008-a026-0e7958655aa9')

      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_key_result_id]).to eq('ad3dcdfc-24e9-4008-a026-0e7958655aa9')
    end

    it 'returns all key results with empty conditions' do
      count = service.query.size
      service.insert(params)

      expect(service.query.size).to eq(count + 1)
    end
  end
end
