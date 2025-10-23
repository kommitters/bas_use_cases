# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/apex_process'
require_relative '../../../src/services/postgres/organizational_unit'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::ApexProcess do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:organizational_unit_service) { Services::Postgres::OrganizationalUnit.new(config) }

  let(:org_unit_id) { @org_unit_id }

  let(:valid_params) do
    {
      external_process_id: 'proc-uuid-1',
      external_org_unit_id: 'org-unit-123',
      name: 'Software Development Lifecycle',
      description: 'Process for developing software',
      start_date: Date.today,
      end_date: Date.today + 30,
      deadline: Date.today + 45,
      status: 'in_progress',
      external_id: 'ext-proc-1'
    }
  end

  before(:each) do
    db.drop_table?(:processes_history)
    db.drop_table?(:processes)
    db.drop_table?(:organizational_units)

    create_organizational_units_table(db)
    create_apex_processes_table(db)
    create_apex_processes_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    @org_unit_id = organizational_unit_service.insert(
      external_org_unit_id: 'org-unit-123',
      name: 'Engineering Department',
      status: 'active'
    )
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new process and returns its ID' do
        id = service.insert(valid_params)
        process = service.find(id)

        expect(process).not_to be_nil
        expect(process[:external_process_id]).to eq(valid_params[:external_process_id])
        expect(process[:org_unit_id]).to eq(org_unit_id)
        expect(process[:name]).to eq(valid_params[:name])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_process_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates a process by ID' do
        id = service.insert(valid_params)
        service.update(id, name: 'Updated Software Development Lifecycle')
        updated = service.find(id)

        expect(updated[:name]).to eq('Updated Software Development Lifecycle')
      end

      it 'reassigns org_unit_id on update with external_org_unit_id' do
        org_unit_id2 = organizational_unit_service.insert(external_org_unit_id: 'org-unit-456', name: 'QA Department',
                                                          status: 'active', external_id: 'ext-org-2')
        id = service.insert(valid_params)

        service.update(id, external_org_unit_id: 'org-unit-456')
        updated = service.find(id)

        expect(updated[:org_unit_id]).to eq(org_unit_id2)
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(status: 'pending', name: 'Initial Process Name')
        id = service.insert(initial_params)

        expect(db[:processes_history].where(process_id: id).all).to be_empty

        update_params = { status: 'completed', name: 'Updated Process Name' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:status]).to eq('completed')
        expect(updated_record[:name]).to eq('Updated Process Name')

        history_records = db[:processes_history].where(process_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:process_id]).to eq(id)
        expect(historical_record[:status]).to eq('pending')
        expect(historical_record[:name]).to eq('Initial Process Name')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, name: 'Oops') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes a process by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a process by ID' do
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
        results = service.query(external_process_id: valid_params[:external_process_id])

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
