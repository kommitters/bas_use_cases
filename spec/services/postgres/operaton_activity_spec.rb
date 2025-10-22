# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/operaton_activity'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::OperatonActivity do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:operaton_activity_service) { described_class.new(config) }

  let(:operaton_activity_params) do
    {
      external_activity_id: 'act-uuid-123',
      external_process_id: 'proc-uuid-123',
      process_definition_key: 'def-key-789',
      activity_id: 'activity-id-1',
      activity_name: 'Task A',
      activity_type: 'UserTask',
      task_id: 'task-id-1',
      assignee: 'john.doe',
      start_time: DateTime.now,
      end_time: nil,
      duration_in_millis: nil
    }
  end

  before(:each) do
    db.drop_table?(:operaton_activities)

    create_operaton_activities_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'inserts an activity' do
      id = operaton_activity_service.insert(operaton_activity_params)
      record = operaton_activity_service.find(id)

      expect(record[:external_activity_id]).to eq(operaton_activity_params[:external_activity_id])
    end
  end

  describe '#update' do
    it 'updates the activity' do
      id = operaton_activity_service.insert(operaton_activity_params)

      operaton_activity_service.update(id, { external_process_id: 'proc-uuid-999', activity_name: 'Updated Task A' })
      updated = operaton_activity_service.find(id)

      expect(updated[:activity_name]).to eq('Updated Task A')
    end
  end

  describe '#delete' do
    it 'deletes the activity' do
      id = operaton_activity_service.insert(operaton_activity_params)

      expect { operaton_activity_service.delete(id) }.to change { operaton_activity_service.query.size }.by(-1)
    end
  end

  describe '#find' do
    it 'finds the activity by ID' do
      id = operaton_activity_service.insert(operaton_activity_params)

      record = operaton_activity_service.find(id)

      expect(record).not_to be_nil
      expect(record[:external_activity_id]).to eq(operaton_activity_params[:external_activity_id])
    end
  end

  describe '#query' do
    it 'returns activities matching the given conditions' do
      operaton_activity_service.insert(operaton_activity_params)

      results = operaton_activity_service.query(external_activity_id: operaton_activity_params[:external_activity_id])

      expect(results.size).to eq(1)
      expect(results.first[:external_activity_id]).to eq(operaton_activity_params[:external_activity_id])
    end
  end
end
