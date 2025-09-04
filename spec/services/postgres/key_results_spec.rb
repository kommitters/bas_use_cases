# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/key_result'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::KeyResult do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }

  let(:valid_params) do
    {
      external_key_result_id: 'ad3dcdfc-24e9-4008-a026-0e7958655aa9',
      okr: 'save time',
      key_result: 'save time result',
      metric: 12,
      current: 56,
      progress: 84,
      period: 'Q2',
      objective: 'save a lot of time'
    }
  end

  before(:each) do
    db.drop_table?(:key_results)
    db.drop_table?(:key_results_history)

    create_key_results_table(db)
    create_key_results_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new key result and returns its ID' do
        id = service.insert(valid_params)
        result = service.find(id)

        expect(result).not_to be_nil
        expect(result[:external_key_result_id]).to eq(valid_params[:external_key_result_id])
        expect(result[:okr]).to eq(valid_params[:okr])
        expect(result[:key_result]).to eq(valid_params[:key_result])
        expect(result[:metric]).to eq(valid_params[:metric])
        expect(result[:current]).to eq(valid_params[:current])
        expect(result[:progress]).to eq(valid_params[:progress])
        expect(result[:period]).to eq(valid_params[:period])
        expect(result[:objective]).to eq(valid_params[:objective])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_key_result_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates a key result by ID' do
        id = service.insert(valid_params)
        service.update(id, key_result: 'Updated result')
        updated = service.find(id)

        expect(updated[:key_result]).to eq('Updated result')
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(progress: 50, key_result: 'Initial State')
        id = service.insert(initial_params)

        expect(db[:key_results_history].where(key_result_id: id).all).to be_empty

        update_params = { progress: 75, key_result: 'Updated State' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:progress]).to eq(75)
        expect(updated_record[:key_result]).to eq('Updated State')

        history_records = db[:key_results_history].where(key_result_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:key_result_id]).to eq(id)
        expect(historical_record[:progress]).to eq(50)
        expect(historical_record[:key_result]).to eq('Initial State')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, key_result: 'Oops') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes a key result by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a key result by ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:key_result]).to eq(valid_params[:key_result])
    end
  end

  describe '#query' do
    context 'with filters' do
      it 'returns filtered results' do
        id = service.insert(valid_params)
        results = service.query(external_key_result_id: valid_params[:external_key_result_id])

        expect(results).not_to be_empty
        expect(results.map { |r| r[:id] }).to include(id)
      end
    end

    context 'without filters' do
      it 'returns all results' do
        initial_count = service.query.size
        service.insert(valid_params)

        expect(service.query.size).to eq(initial_count + 1)
      end
    end
  end
end
