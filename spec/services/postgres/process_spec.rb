# frozen_string_literal: true

require 'rspec'
require 'sequel'
require_relative '../../../src/services/postgres/process'

describe Services::Postgres::Process do
  let(:db) { Sequel.sqlite } # Use an in-memory SQLite database for testing
  let(:service) { described_class.new(db) }

  before do
    db.create_table!(:processes) do
      primary_key :id
      String :external_process_id
      String :business_key
      String :process_definition_key
      String :process_definition_name
      DateTime :start_time
      DateTime :end_time
      Integer :duration_in_millis # Changed from Bignum to Integer for SQLite compatibility
      Integer :process_definition_version
      String :state
    end
  end

  after do
    db.drop_table(:processes)
  end

  describe '#insert' do
    it 'inserts a new process' do
      process_data = {
        external_process_id: '123',
        business_key: 'abc',
        process_definition_key: 'key-1',
        process_definition_name: 'Test Process',
        start_time: Time.now,
        end_time: Time.now,
        duration_in_millis: 1000,
        process_definition_version: 1,
        state: 'COMPLETED'
      }
      id = service.insert(process_data)
      expect(id).not_to be_nil
      expect(service.find(id)[:external_process_id]).to eq('123')
    end
  end
end
