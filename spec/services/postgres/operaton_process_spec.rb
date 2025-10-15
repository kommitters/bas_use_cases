# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/operaton_process'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::OperatonProcess do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:operaton_process_service) { described_class.new(config) }

  let(:operaton_process_params) do
    {
      external_process_id: 'proc-uuid-123',
      business_key: 'biz-key-456',
      process_definition_key: 'def-key-789',
      process_definition_name: 'My Process',
      start_time: DateTime.now,
      end_time: nil,
      duration_in_millis: nil,
      process_definition_version: '1.0',
      state: 'ACTIVE'
    }
  end

  before(:each) do
    db.drop_table?(:operaton_processes)
    create_operaton_processes_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'inserts a process' do
      id = operaton_process_service.insert(operaton_process_params)
      record = operaton_process_service.find(id)

      expect(record[:external_process_id]).to eq(operaton_process_params[:external_process_id])
      expect(record[:process_definition_name]).to eq(operaton_process_params[:process_definition_name])
    end
  end

  describe '#update' do
    it 'updates the process' do
      id = operaton_process_service.insert(operaton_process_params)

      operaton_process_service.update(id, { business_key: 'updated-biz-key', state: 'COMPLETED' })
      updated = operaton_process_service.find(id)

      expect(updated[:business_key]).to eq('updated-biz-key')
      expect(updated[:state]).to eq('COMPLETED')
    end
  end

  describe '#delete' do
    it 'deletes the process' do
      id = operaton_process_service.insert(operaton_process_params)

      expect { operaton_process_service.delete(id) }.to change { operaton_process_service.query.size }.by(-1)
    end
  end

  describe '#find' do
    it 'finds the process by ID' do
      id = operaton_process_service.insert(operaton_process_params)

      record = operaton_process_service.find(id)

      expect(record).not_to be_nil
      expect(record[:external_process_id]).to eq(operaton_process_params[:external_process_id])
    end
  end

  describe '#query' do
    it 'returns processes matching the given conditions' do
      operaton_process_service.insert(operaton_process_params)

      results = operaton_process_service.query(external_process_id: operaton_process_params[:external_process_id])

      expect(results.size).to eq(1)
      expect(results.first[:external_process_id]).to eq(operaton_process_params[:external_process_id])
    end
  end
end
