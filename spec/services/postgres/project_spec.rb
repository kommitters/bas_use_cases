# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/project'

RSpec.describe Services::Project do
  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }

  # Create the table structure before each test (so 'db' from let is available)
  before(:each) do
    db.drop_table?(:project)
    db.create_table(:project) do
      primary_key :id
      String :external_project_id, null: false
      String :name, null: false
      String :type, size: 100, null: false
      String :weekly_scope_id
      String :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
    # Inject the in-memory DB connection into the service
    allow_any_instance_of(Services::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new project and returns its ID' do
      params = {
        external_project_id: 'ext-p-1',
        name: 'Sample Project',
        type: 'internal'
      }
      id = service.insert(params)
      project = service.find(id)
      expect(project[:name]).to eq('Sample Project')
      expect(project[:external_project_id]).to eq('ext-p-1')
      expect(project[:type]).to eq('internal')
    end
  end

  describe '#update' do
    it 'updates a project by ID' do
      id = service.insert(external_project_id: 'ext-p-2', name: 'To Update', type: 'external')
      service.update(id: id, name: 'Updated Project')
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Project')
      expect(updated[:type]).to eq('external')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a project by ID' do
      id = service.insert(external_project_id: 'ext-p-3', name: 'To Delete', type: 'archive')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a project by ID' do
      id = service.insert(external_project_id: 'ext-p-4', name: 'Find Me', type: 'active')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:type]).to eq('active')
    end
  end

  describe '#query' do
    it 'queries projects by condition' do
      id = service.insert(external_project_id: 'ext-p-5', name: 'Query Me', type: 'special')
      results = service.query(name: 'Query Me')
      expect(results.map { |p| p[:id] }).to include(id)
      expect(results.first[:type]).to eq('special')
    end

    it 'returns all projects with empty conditions' do
      count = service.query.size
      service.insert(external_project_id: 'ext-p-6', name: 'Another', type: 'misc')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
