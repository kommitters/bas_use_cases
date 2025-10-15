# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/operaton_process'
require_relative '../../../src/services/postgres/operaton_incident'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::OperatonIncident do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:operaton_incident_service) { described_class.new(config) }

  let(:operaton_incident_params) do
    {
      external_incident_id: 'inc-uuid-123',
      external_process_id: 'proc-uuid-123',
      process_definition_key: 'def-key-789',
      activity_id: 'activity-id-1',
      incident_type: 'JobFailed',
      incident_message: 'Error in task',
      resolved: false,
      create_time: DateTime.now,
      end_time: nil
    }
  end

  before(:each) do
    db.drop_table?(:operaton_incidents)
    db.drop_table?(:operaton_processes)

    create_operaton_processes_table(db)
    create_operaton_incidents_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'inserts an incident' do
      id = operaton_incident_service.insert(operaton_incident_params)
      record = operaton_incident_service.find(id)

      expect(record[:external_incident_id]).to eq(operaton_incident_params[:external_incident_id])
    end
  end

  describe '#update' do
    it 'updates the incident' do
      id = operaton_incident_service.insert(operaton_incident_params)

      operaton_incident_service.update(id, { external_process_id: 'proc-uuid-999', resolved: true })
      updated = operaton_incident_service.find(id)

      expect(updated[:resolved]).to be(true)
    end
  end

  describe '#delete' do
    it 'deletes the incident' do
      id = operaton_incident_service.insert(operaton_incident_params)

      expect { operaton_incident_service.delete(id) }.to change { operaton_incident_service.query.size }.by(-1)
    end
  end

  describe '#find' do
    it 'finds the incident by ID' do
      id = operaton_incident_service.insert(operaton_incident_params)

      record = operaton_incident_service.find(id)

      expect(record).not_to be_nil
      expect(record[:external_incident_id]).to eq(operaton_incident_params[:external_incident_id])
    end
  end

  describe '#query' do
    it 'returns incidents matching the given conditions' do
      operaton_incident_service.insert(operaton_incident_params)

      results = operaton_incident_service.query(external_incident_id: operaton_incident_params[:external_incident_id])

      expect(results.size).to eq(1)
      expect(results.first[:external_incident_id]).to eq(operaton_incident_params[:external_incident_id])
    end
  end
end
