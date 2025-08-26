# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/milestone'
require_relative '../../../src/services/postgres/project'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Milestone do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:project_service) { Services::Postgres::Project.new(config) }

  before(:each) do
    db.drop_table?(:milestones)
    db.drop_table?(:projects)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_milestones_table(db)
    create_projects_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new milestone and returns its ID' do
      params = {
        external_milestone_id: 'ext-m-1',
        name: 'Milestone One',
        status: 'active'
      }
      id = service.insert(params)
      milestone = service.find(id)
      expect(milestone[:name]).to eq('Milestone One')
      expect(milestone[:external_milestone_id]).to eq('ext-m-1')
      expect(milestone[:status]).to eq('active')
    end

    it 'assigns project_id when given external_project_id' do
      project_id = project_service.insert(external_project_id: 'proj-1', name: 'Project1', status: 'active')
      params = {
        external_milestone_id: 'ext-m-2',
        name: 'With Project',
        status: 'done',
        external_project_id: 'proj-1'
      }
      id = service.insert(params)
      milestone = service.find(id)
      expect(milestone[:project_id]).to eq(project_id)
    end

    it 'removes external_project_id if it is present and nil' do
      params = {
        external_milestone_id: 'ext-m-3',
        name: 'Nil Project',
        status: 'inactive',
        external_project_id: nil
      }
      id = service.insert(params)
      milestone = service.find(id)
      expect(milestone).not_to have_key(:external_project_id)
      expect(milestone[:project_id]).to be_nil
    end

    it 'creates a new historical record when inserting a milestone with the same external_id' do
      params1 = {
        external_milestone_id: 'm-hist-1',
        name: 'Milestone V1',
        status: 'open'
      }
      service.insert(params1)

      expect(service.query(external_milestone_id: 'm-hist-1').size).to eq(1)

      params2 = {
        external_milestone_id: 'm-hist-1',
        name: 'Milestone V2 - Closed',
        status: 'closed'
      }
      service.insert(params2)

      milestones = service.query(external_milestone_id: 'm-hist-1')
      expect(milestones.size).to eq(2)

      names = milestones.map { |m| m[:name] }.sort
      statuses = milestones.map { |m| m[:status] }

      expect(names).to eq(['Milestone V1', 'Milestone V2 - Closed'])
      expect(statuses).to contain_exactly('open', 'closed')
    end
  end

  describe '#update' do
    it 'updates a milestone by ID' do
      id = service.insert(external_milestone_id: 'ext-m-4', name: 'Old Name', status: 'open')
      service.update(id, { name: 'Updated Name', status: 'closed' })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Name')
      expect(updated[:status]).to eq('closed')
      expect(updated[:external_milestone_id]).to eq('ext-m-4')
    end

    it 'reassigns project_id on update with external_project_id' do
      project2 = project_service.insert(external_project_id: 'proj-2', name: 'Project2', status: 'active')
      id = service.insert(
        external_milestone_id: 'ext-m-5',
        name: 'To Update Project',
        status: 'open',
        external_project_id: 'proj-1'
      )
      service.update(id, { external_project_id: 'proj-2' })
      updated = service.find(id)
      expect(updated[:project_id]).to eq(project2)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a milestone by ID' do
      id = service.insert(external_milestone_id: 'ext-m-6', name: 'To Delete', status: 'active')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a milestone by ID' do
      id = service.insert(external_milestone_id: 'ext-m-7', name: 'Find Me', status: 'active')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_milestone_id]).to eq('ext-m-7')
      expect(found[:status]).to eq('active')
    end
  end

  describe '#query' do
    it 'queries milestones by condition' do
      id = service.insert(external_milestone_id: 'ext-m-8', name: 'Query Me', status: 'active')
      results = service.query(name: 'Query Me')
      expect(results.map { |m| m[:id] }).to include(id)
      expect(results.first[:external_milestone_id]).to eq('ext-m-8')
    end

    it 'returns all milestones with empty conditions' do
      count = service.query.size
      service.insert(external_milestone_id: 'ext-m-9', name: 'Another', status: 'active')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
