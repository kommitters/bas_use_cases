# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/okr'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Okr do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }

  let(:valid_params) do
    {
      external_okr_id: 'okr-uuid-123',
      code: 'OKR-001',
      status: 'active',
      objective: 'Increase market share'
    }
  end

  before(:each) do
    db.drop_table?(:okrs_history)
    db.drop_table?(:okrs)

    create_okrs_table(db)
    create_okrs_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new okr and returns its ID' do
        id = service.insert(valid_params)
        okr = service.find(id)

        expect(okr).not_to be_nil
        expect(okr[:external_okr_id]).to eq(valid_params[:external_okr_id])
        expect(okr[:code]).to eq(valid_params[:code])
        expect(okr[:status]).to eq(valid_params[:status])
        expect(okr[:objective]).to eq(valid_params[:objective])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_okr_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates an okr by ID' do
        id = service.insert(valid_params)
        service.update(id, code: 'OKR-002')
        updated = service.find(id)

        expect(updated[:code]).to eq('OKR-002')
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(status: 'pending', code: 'OKR-001')
        id = service.insert(initial_params)

        expect(db[:okrs_history].where(okr_id: id).all).to be_empty

        update_params = { status: 'completed', code: 'OKR-002' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:status]).to eq('completed')
        expect(updated_record[:code]).to eq('OKR-002')

        history_records = db[:okrs_history].where(okr_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:okr_id]).to eq(id)
        expect(historical_record[:status]).to eq('pending')
        expect(historical_record[:code]).to eq('OKR-001')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, code: 'OKR-003') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes an okr by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves an okr by ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:code]).to eq(valid_params[:code])
    end
  end

  describe '#query' do
    context 'with filters' do
      it 'returns filtered results' do
        id = service.insert(valid_params)
        results = service.query(external_okr_id: valid_params[:external_okr_id])

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
