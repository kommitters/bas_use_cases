# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/work_item'
require_relative '../../../src/services/postgres/project'
require_relative '../../../src/services/postgres/activity'
require_relative '../../../src/services/postgres/domain'
require_relative '../../../src/services/postgres/person'
require_relative '../../../src/services/postgres/weekly_scope'
require_relative '../../../src/services/postgres/github_issue'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::WorkItem do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:project_service) { Services::Postgres::Project.new(config) }
  let(:activity_service) { Services::Postgres::Activity.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }
  let(:weekly_scope_service) { Services::Postgres::WeeklyScope.new(config) }
  let(:github_issue_service) { Services::Postgres::GithubIssue.new(config) }

  before(:each) do
    db.drop_table?(:work_items_history)
    db.drop_table?(:work_items)
    db.drop_table?(:projects)
    db.drop_table?(:activities)
    db.drop_table?(:domains)
    db.drop_table?(:persons)
    db.drop_table?(:weekly_scopes)
    db.drop_table?(:github_issues)

    create_projects_table(db)
    create_activities_table(db)
    create_domains_table(db)
    create_persons_table(db)
    create_work_items_table(db)
    create_weekly_scopes_table(db)
    create_github_issues_table(db)
    create_work_items_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new work_item and returns its ID' do
      params = {
        external_work_item_id: 'ext-wi-1',
        name: 'Test Work Item',
        status: 'open'
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item[:name]).to eq('Test Work Item')
      expect(work_item[:external_work_item_id]).to eq('ext-wi-1')
      expect(work_item[:status]).to eq('open')
    end

    it 'assigns all foreign keys when given their external ids' do
      project_id = project_service.insert(external_project_id: 'proj-1', name: 'Proj1', status: 'active')
      activity_id = activity_service.insert(external_activity_id: 'act-1', name: 'Act1')
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Dom1')
      person_id = person_service.insert(external_person_id: 'per-1', full_name: 'Person1')
      weekly_scope_id = weekly_scope_service.insert(external_weekly_scope_id: 'ws-1', description: 'weekly scope')
      github_issue_id = github_issue_service.insert(external_github_issue_id: 'ext-issue-1', repository_id: 123,
                                                    external_person_id: 'per-1')
      params = {
        external_work_item_id: 'ext-wi-2',
        name: 'WorkItem with FKs',
        status: 'done',
        external_project_id: 'proj-1',
        external_activity_id: 'act-1',
        external_domain_id: 'dom-1',
        external_person_id: 'per-1',
        external_weekly_scope_id: 'ws-1',
        external_github_issue_id: 'ext-issue-1'
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item[:project_id]).to eq(project_id)
      expect(work_item[:activity_id]).to eq(activity_id)
      expect(work_item[:domain_id]).to eq(domain_id)
      expect(work_item[:person_id]).to eq(person_id)
      expect(work_item[:weekly_scope_id]).to eq(weekly_scope_id)
      expect(work_item[:github_issue_id]).to eq(github_issue_id)
    end

    it 'removes all external ids from params even if nil' do
      params = {
        external_work_item_id: 'ext-wi-3',
        name: 'WorkItem Nil FKs',
        status: 'pending',
        external_project_id: nil,
        external_activity_id: nil,
        external_domain_id: nil,
        external_person_id: nil,
        external_weekly_scope_id: nil
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item).not_to have_key(:external_project_id)
      expect(work_item).not_to have_key(:external_activity_id)
      expect(work_item).not_to have_key(:external_domain_id)
      expect(work_item).not_to have_key(:external_person_id)
      expect(work_item).not_to have_key(:external_weekly_scope_id)
      expect(work_item[:project_id]).to be_nil
      expect(work_item[:activity_id]).to be_nil
      expect(work_item[:domain_id]).to be_nil
      expect(work_item[:person_id]).to be_nil
      expect(work_item[:weekly_scope_id]).to be_nil
    end
  end

  describe '#update' do
    it 'updates a work_item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-4', name: 'Old Name', status: 'open')
      service.update(id, { name: 'Updated Name', status: 'closed' })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Name')
      expect(updated[:status]).to eq('closed')
      expect(updated[:external_work_item_id]).to eq('ext-wi-4')
    end

    it 'reassigns foreign keys on update with external ids' do
      project2 = project_service.insert(external_project_id: 'proj-2', name: 'Proj2', status: 'active')
      id = service.insert(
        external_work_item_id: 'ext-wi-5',
        name: 'WorkItem to Update FKs',
        status: 'open',
        external_project_id: 'proj-1'
      )
      service.update(id, { external_project_id: 'proj-2' })
      updated = service.find(id)
      expect(updated[:project_id]).to eq(project2)
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(external_work_item_id: 'wi-hist-1', name: 'Initial Task', status: 'To Do')

      expect(db[:work_items_history].where(work_item_id: id).all).to be_empty

      service.update(id, { name: 'Updated Task', status: 'In Progress' })

      updated_record = service.find(id)
      expect(updated_record[:name]).to eq('Updated Task')
      expect(updated_record[:status]).to eq('In Progress')

      history_records = db[:work_items_history].where(work_item_id: id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:work_item_id]).to eq(id)
      expect(historical_record[:name]).to eq('Initial Task')
      expect(historical_record[:status]).to eq('To Do')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a work_item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-6', name: 'To Delete', status: 'open')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a work_item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-7', name: 'Find Me', status: 'open')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_work_item_id]).to eq('ext-wi-7')
      expect(found[:status]).to eq('open')
    end
  end

  describe '#query' do
    it 'queries work_items by condition' do
      id = service.insert(external_work_item_id: 'ext-wi-8', name: 'Query Me', status: 'open')
      results = service.query(name: 'Query Me')
      expect(results.map { |wi| wi[:id] }).to include(id)
      expect(results.first[:external_work_item_id]).to eq('ext-wi-8')
    end

    it 'returns all work_items with empty conditions' do
      count = service.query.size
      service.insert(external_work_item_id: 'ext-wi-9', name: 'Another', status: 'closed')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
