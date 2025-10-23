# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'date'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/apex_milestone'
require_relative '../../../src/services/postgres/kr'
require_relative '../../../src/services/postgres/okr'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::ApexMilestone do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:kr_service) { Services::Postgres::Kr.new(config) }
  let(:okr_service) { Services::Postgres::Okr.new(config) }

  let(:okr_id) { @okr_id }

  let(:kr_id) { @kr_id }

  let(:valid_params) do
    {
      external_apex_milestone_id: 'apex-milestone-1',
      external_kr_id: 'kr-uuid-456',
      description: 'Complete phase 1',
      milestone_order: 1,
      percentage: 0.5,
      completion_date: Date.today + 30,
      is_completed: false
    }
  end

  before(:each) do
    db.drop_table?(:apex_milestones_history)
    db.drop_table?(:apex_milestones)
    db.drop_table?(:krs_history)
    db.drop_table?(:krs)
    db.drop_table?(:okrs_history)
    db.drop_table?(:okrs)

    create_okrs_table(db)
    create_okrs_history_table(db)
    create_krs_table(db)
    create_krs_history_table(db)
    create_apex_milestones_table(db)
    create_apex_milestones_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    @okr_id = okr_service.insert(
      external_okr_id: 'okr-uuid-123',
      code: 'OKR-001',
      status: 'active',
      objective: 'Increase market share'
    )

    @kr_id = kr_service.insert(
      external_kr_id: 'kr-uuid-456',
      external_okr_id: 'okr-uuid-123',
      description: 'Achieve 10% growth',
      status: 'on_track',
      code: 'KR-001'
    )
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new apex milestone and returns its ID' do
        id = service.insert(valid_params)
        apex_milestone = service.find(id)

        expect(apex_milestone).not_to be_nil
        expect(apex_milestone[:external_apex_milestone_id]).to eq(valid_params[:external_apex_milestone_id])
        expect(apex_milestone[:kr_id]).to eq(kr_id)
        expect(apex_milestone[:description]).to eq(valid_params[:description])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_apex_milestone_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates an apex milestone by ID' do
        id = service.insert(valid_params)
        service.update(id, description: 'Complete phase 2')
        updated = service.find(id)

        expect(updated[:description]).to eq('Complete phase 2')
      end

      it 'reassigns kr_id on update with external_kr_id' do
        okr_service.insert(external_okr_id: 'okr-uuid-999', code: 'OKR-002', status: 'active',
                           objective: 'New Objective')
        new_kr_id = kr_service.insert(external_kr_id: 'kr-uuid-789', external_okr_id: 'okr-uuid-999',
                                      description: 'New KR', status: 'on_track', code: 'KR-002')
        id = service.insert(valid_params)

        service.update(id, external_kr_id: 'kr-uuid-789')
        updated = service.find(id)

        expect(updated[:kr_id]).to eq(new_kr_id)
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(percentage: 0.25, description: 'Initial description')
        id = service.insert(initial_params)

        expect(db[:apex_milestones_history].where(apex_milestone_id: id).all).to be_empty

        update_params = { percentage: 0.75, description: 'Updated description' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:percentage]).to eq(0.75)
        expect(updated_record[:description]).to eq('Updated description')

        history_records = db[:apex_milestones_history].where(apex_milestone_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:apex_milestone_id]).to eq(id)
        expect(historical_record[:percentage]).to eq(0.25)
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
    it 'removes an apex milestone by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves an apex milestone by ID' do
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
        results = service.query(external_apex_milestone_id: valid_params[:external_apex_milestone_id])

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
