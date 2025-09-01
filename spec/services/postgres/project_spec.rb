# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/project'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Project do
  include TestDBHelpers

  # Setup in-memory SQLite DB for testing
  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  let(:history_service) { Services::Postgres::HistoryService.new(config, :projects_history, :project_id) }

  before(:each) do
    db.drop_table?(:projects_history)
    db.drop_table?(:projects)
    db.drop_table?(:domains)

    create_projects_table(db)
    create_domains_table(db)
    create_projects_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new project and returns its ID' do
      params = {
        external_project_id: 'ext-p-1',
        name: 'Project One',
        status: 'active'
      }
      id = service.insert(params)
      project = service.find(id)
      expect(project[:name]).to eq('Project One')
      expect(project[:external_project_id]).to eq('ext-p-1')
      expect(project[:status]).to eq('active')
    end

    it 'assigns domain_id when given external_domain_id' do
      domain_id = domain_service.insert(external_domain_id: 'ext-d-1', name: 'Domain1')
      params = {
        external_project_id: 'ext-p-2',
        name: 'With Domain',
        status: 'active',
        external_domain_id: 'ext-d-1'
      }
      id = service.insert(params)
      project = service.find(id)
      expect(project[:domain_id]).to eq(domain_id)
    end
    it 'removes external_domain_id if it is present and nil' do
      params = {
        external_project_id: 'ext-p-9',
        name: 'Project Nil External',
        status: 'inactive',
        external_domain_id: nil
      }
      id = service.insert(params)
      project = service.find(id)
      expect(project).not_to have_key(:external_domain_id)
      expect(project[:domain_id]).to be_nil
    end
  end

  describe '#update' do
    it 'updates a project by ID' do
      id = service.insert(external_project_id: 'ext-p-3', name: 'Old Name', status: 'inactive')
      service.update(id, { name: 'New Name', status: 'active' })
      updated = service.find(id)
      expect(updated[:name]).to eq('New Name')
      expect(updated[:status]).to eq('active')
      expect(updated[:external_project_id]).to eq('ext-p-3')
    end

    it 'reassigns domain_id on update with external_domain_id' do
      domain2 = domain_service.insert(external_domain_id: 'domain-2', name: 'Domain2')
      id = service.insert(external_project_id: 'ext-p-4', name: 'Proj', status: 'active',
                          external_domain_id: 'domain-1')
      service.update(id, { external_domain_id: 'domain-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain2)
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(external_project_id: 'proj-hist-1', name: 'Initial Project', status: 'active')

      expect(history_service.query(project_id: id)).to be_empty

      service.update(id, { name: 'Updated Project', status: 'archived' })

      updated_record = service.find(id)
      expect(updated_record[:name]).to eq('Updated Project')
      expect(updated_record[:status]).to eq('archived')

      history_records = history_service.query(project_id: id)
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:project_id]).to eq(id)
      expect(historical_record[:name]).to eq('Initial Project')
      expect(historical_record[:status]).to eq('active')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a project by ID' do
      id = service.insert(external_project_id: 'ext-p-5', name: 'To Delete', status: 'active')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a project by ID' do
      id = service.insert(external_project_id: 'ext-p-6', name: 'Find Me', status: 'active')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_project_id]).to eq('ext-p-6')
      expect(found[:status]).to eq('active')
    end
  end

  describe '#query' do
    it 'queries projects by condition' do
      id = service.insert(external_project_id: 'ext-p-7', name: 'Query Me', status: 'active')
      results = service.query(name: 'Query Me')
      expect(results.map { |p| p[:id] }).to include(id)
      expect(results.first[:external_project_id]).to eq('ext-p-7')
    end

    it 'returns all projects with empty conditions' do
      count = service.query.size
      service.insert(external_project_id: 'ext-p-8', name: 'Another', status: 'inactive')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
