# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/organizational_unit'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::OrganizationalUnit do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }

  let(:valid_params) do
    {
      external_org_unit_id: 'org-unit-123',
      name: 'Engineering Department',
      status: 'active'
    }
  end

  before(:each) do
    db.drop_table?(:organizational_units_history)
    db.drop_table?(:organizational_units)

    create_organizational_units_table(db)
    create_organizational_units_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new organizational unit and returns its ID' do
        id = service.insert(valid_params)
        org_unit = service.find(id)

        expect(org_unit).not_to be_nil
        expect(org_unit[:external_org_unit_id]).to eq(valid_params[:external_org_unit_id])
        expect(org_unit[:name]).to eq(valid_params[:name])
        expect(org_unit[:status]).to eq(valid_params[:status])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_org_unit_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates an organizational unit by ID' do
        id = service.insert(valid_params)
        service.update(id, name: 'Updated Engineering Department')
        updated = service.find(id)

        expect(updated[:name]).to eq('Updated Engineering Department')
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(status: 'pending', name: 'Initial Name')
        id = service.insert(initial_params)

        expect(db[:organizational_units_history].where(organizational_unit_id: id).all).to be_empty

        update_params = { status: 'completed', name: 'Updated Name' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:status]).to eq('completed')
        expect(updated_record[:name]).to eq('Updated Name')

        history_records = db[:organizational_units_history].where(organizational_unit_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:organizational_unit_id]).to eq(id)
        expect(historical_record[:status]).to eq('pending')
        expect(historical_record[:name]).to eq('Initial Name')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, name: 'Oops') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes an organizational unit by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves an organizational unit by ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:name]).to eq(valid_params[:name])
    end
  end

  describe '#query' do
    context 'with filters' do
      it 'returns filtered results' do
        id = service.insert(valid_params)
        results = service.query(external_org_unit_id: valid_params[:external_org_unit_id])

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
