# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/activity'

RSpec.describe Services::Activity do
  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:activity)
    db.create_table(:activity) do
      primary_key :id
      String :external_activity_id, null: false
      String :name, null: false
      String :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
    # Inject the in-memory DB connection into the service
    allow_any_instance_of(Services::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new activity and returns its ID' do
      params = {
        external_activity_id: 'ext-a-1',
        name: 'Sample Activity'
      }
      id = service.insert(params)
      activity = service.find(id)
      expect(activity[:name]).to eq('Sample Activity')
      expect(activity[:external_activity_id]).to eq('ext-a-1')
    end
  end

  describe '#update' do
    it 'updates an activity by ID' do
      id = service.insert(external_activity_id: 'ext-a-2', name: 'To Update')
      service.update(id: id, name: 'Updated Activity')
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Activity')
      expect(updated[:external_activity_id]).to eq('ext-a-2')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes an activity by ID' do
      id = service.insert(external_activity_id: 'ext-a-3', name: 'To Delete')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds an activity by ID' do
      id = service.insert(external_activity_id: 'ext-a-4', name: 'Find Me')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_activity_id]).to eq('ext-a-4')
    end
  end

  describe '#query' do
    it 'queries activities by condition' do
      id = service.insert(external_activity_id: 'ext-a-5', name: 'Query Me')
      results = service.query(name: 'Query Me')
      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_activity_id]).to eq('ext-a-5')
    end

    it 'returns all activities with empty conditions' do
      count = service.query.size
      service.insert(external_activity_id: 'ext-a-6', name: 'Another')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
