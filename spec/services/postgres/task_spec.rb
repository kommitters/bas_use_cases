# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/task'
require_relative '../../../src/services/postgres/apex_process'
require_relative '../../../src/services/postgres/apex_milestone'
require_relative '../../../src/services/postgres/organizational_unit'
require_relative '../../../src/services/postgres/kr'
require_relative '../../../src/services/postgres/okr'

require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Task do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:apex_process_service) { Services::Postgres::ApexProcess.new(config) }
  let(:apex_milestone_service) { Services::Postgres::ApexMilestone.new(config) }
  let(:organizational_unit_service) { Services::Postgres::OrganizationalUnit.new(config) }
  let(:okr_service) { Services::Postgres::Okr.new(config) }
  let(:kr_service) { Services::Postgres::Kr.new(config) }

  let(:okr_id) { @okr_id }
  let(:kr_id) { @kr_id }
  let(:org_unit_id) { @org_unit_id }
  let(:process_id) { @process_id }
  let(:milestone_id) { @milestone_id }

  let(:valid_params) do
    {
      external_task_id: 'task-uuid-1',
      external_process_id: 'proc-uuid-1',
      external_apex_milestone_id: 'ext-m-1',
      name: 'Implement Feature X',
      description: 'Develop and test feature X',
      assigned_to: 'John Doe',
      status: 'to_do',
      start_date: Date.today,
      end_date: Date.today + 7,
      deadline: Date.today + 10
    }
  end

  before(:each) do
    db.drop_table?(:tasks_history)
    db.drop_table?(:tasks)
    db.drop_table?(:processes_history)
    db.drop_table?(:processes)
    db.drop_table?(:apex_milestones_history)
    db.drop_table?(:apex_milestones)
    db.drop_table?(:organizational_units_history)
    db.drop_table?(:organizational_units)
    db.drop_table?(:krs_history)
    db.drop_table?(:krs)
    db.drop_table?(:okrs_history)
    db.drop_table?(:okrs)

    create_okrs_table(db)
    create_okrs_history_table(db)
    create_krs_table(db)
    create_krs_history_table(db)
    create_organizational_units_table(db)
    create_organizational_units_history_table(db)
    create_apex_processes_table(db)
    create_apex_processes_history_table(db)
    create_apex_milestones_table(db)
    create_apex_milestones_history_table(db)
    create_tasks_table(db)
    create_tasks_history_table(db)

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

    @org_unit_id = organizational_unit_service.insert(
      external_org_unit_id: 'org-unit-123',
      name: 'Engineering Department',
      status: 'active'
    )

    @process_id = apex_process_service.insert(
      external_process_id: 'proc-uuid-1',
      external_org_unit_id: 'org-unit-123',
      name: 'Software Development Lifecycle',
      description: 'Process for developing software',
      start_date: Date.today,
      end_date: Date.today + 30,
      deadline: Date.today + 45,
      status: 'in_progress',
      external_id: 'ext-proc-1'
    )

    @milestone_id = apex_milestone_service.insert(
      external_apex_milestone_id: 'ext-m-1',
      external_kr_id: 'kr-uuid-456',
      name: 'Milestone One',
      description: 'First milestone description',
      milestone_order: 1,
      percentage: 0.5,
      completion_date: Date.today + 30,
      is_completed: false
    )
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new task and returns its ID' do
        id = service.insert(valid_params)
        task = service.find(id)

        expect(task).not_to be_nil
        expect(task[:external_task_id]).to eq(valid_params[:external_task_id])
        expect(task[:process_id]).to eq(process_id)
        expect(task[:milestone_id]).to eq(milestone_id)
        expect(task[:name]).to eq(valid_params[:name])
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_task_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates a task by ID' do
        id = service.insert(valid_params)
        service.update(id, name: 'Implement Feature Y')
        updated = service.find(id)

        expect(updated[:name]).to eq('Implement Feature Y')
      end

      it 'reassigns process_id on update with external_process_id' do
        organizational_unit_service.insert(external_org_unit_id: 'org-unit-456',
                                           name: 'QA Department', status: 'active', external_id: 'ext-org-2')
        new_process_id = apex_process_service.insert(external_process_id: 'proc-uuid-2',
                                                     external_org_unit_id: 'org-unit-456', name: 'QA Process',
                                                     description: 'Process for QA', start_date: Date.today,
                                                     end_date: Date.today + 10, deadline: Date.today + 15,
                                                     status: 'in_progress', external_id: 'ext-proc-2')
        id = service.insert(valid_params)

        service.update(id, external_process_id: 'proc-uuid-2')
        updated = service.find(id)

        expect(updated[:process_id]).to eq(new_process_id)
      end

      it 'reassigns milestone_id on update with external_apex_milestone_id' do
        new_milestone_id = apex_milestone_service.insert(
          external_apex_milestone_id: 'ext-m-2',
          external_kr_id: 'kr-uuid-456',
          description: 'Second milestone description',
          milestone_order: 2,
          percentage: 0.75,
          completion_date: Date.today + 60,
          is_completed: false
        )
        id = service.insert(valid_params)

        service.update(id, external_apex_milestone_id: 'ext-m-2')
        updated = service.find(id)

        expect(updated[:milestone_id]).to eq(new_milestone_id)
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(status: 'pending', name: 'Initial Task Name')
        id = service.insert(initial_params)

        expect(db[:tasks_history].where(task_id: id).all).to be_empty

        update_params = { status: 'completed', name: 'Updated Task Name' }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:status]).to eq('completed')
        expect(updated_record[:name]).to eq('Updated Task Name')

        history_records = db[:tasks_history].where(task_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:task_id]).to eq(id)
        expect(historical_record[:status]).to eq('pending')
        expect(historical_record[:name]).to eq('Initial Task Name')
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, name: 'Oops') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    it 'removes a task by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a task by ID' do
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
        results = service.query(external_task_id: valid_params[:external_task_id])

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
