# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/kr'
require_relative '../../../src/services/postgres/okr'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Kr do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:okr_service) { Services::Postgres::Okr.new(config) }

  let(:okr_id) { @okr_id }

  let(:valid_params) do
    {
      external_kr_id: 'kr-uuid-456',
      external_okr_id: 'okr-uuid-123',
      description: 'Achieve 10% growth',
      status: 'on_track',
      code: 'KR-001'
    }
  end

  before(:each) do
    db.drop_table?(:krs_history)
    db.drop_table?(:krs)
    db.drop_table?(:okrs)

    create_okrs_table(db)
    create_krs_table(db)
    create_krs_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    @okr_id = okr_service.insert(
      external_okr_id: 'okr-uuid-123',
      code: 'OKR-001',
      status: 'active',
      objective: 'Increase market share'
    )
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new kr and returns its ID' do
        id = service.insert(valid_params)
        kr = service.find(id)

        expect(kr).not_to be_nil
        expect(kr[:external_kr_id]).to eq(valid_params[:external_kr_id])
        expect(kr[:okr_id]).to eq(okr_id)
        expect(kr[:description]).to eq(valid_params[:description])
        expect(kr[:status]).to eq(valid_params[:status])
        expect(kr[:code]).to eq(valid_params[:code])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_kr_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates a kr by ID' do
        id = service.insert(valid_params)
        service.update(id, description: 'Achieve 15% growth')
        updated = service.find(id)

        expect(updated[:description]).to eq('Achieve 15% growth')
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(status: 'at_risk', description: 'Initial description')
        id = service.insert(initial_params)

        expect(db[:krs_history].where(kr_id: id).all).to be_empty

        update_params = { status: 'completed', description: 'Updated description' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:status]).to eq('completed')
        expect(updated_record[:description]).to eq('Updated description')

        history_records = db[:krs_history].where(kr_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:kr_id]).to eq(id)
        expect(historical_record[:status]).to eq('at_risk')
        expect(historical_record[:description]).to eq('Initial description')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, description: 'Oops') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes a kr by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a kr by ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:description]).to eq(valid_params[:description])
    end
  end

  describe '#query' do
    context 'with filters' do
      it 'returns filtered results' do
        id = service.insert(valid_params)
        results = service.query(external_kr_id: valid_params[:external_kr_id])

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
