# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/work_log'
require_relative '../../../src/services/postgres/project'
require_relative '../../../src/services/postgres/activity'
require_relative '../../../src/services/postgres/domain'
require_relative '../../../src/services/postgres/person'
require_relative '../../../src/services/postgres/work_item'
require_relative 'test_db_helpers'
require 'json'

RSpec.describe Services::Postgres::WorkLog do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:project_service) { Services::Postgres::Project.new(config) }
  let(:activity_service) { Services::Postgres::Activity.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }
  let(:work_item_service) { Services::Postgres::WorkItem.new(config) }

  before(:each) do
    db.drop_table?(:work_logs)
    db.drop_table?(:projects)
    db.drop_table?(:activities)
    db.drop_table?(:domains)
    db.drop_table?(:persons)
    db.drop_table?(:work_items)
    db.drop_table?(:weekly_scopes)

    create_projects_table(db)
    create_activities_table(db)
    create_domains_table(db)
    create_persons_table(db)
    create_work_items_table(db)
    create_work_logs_table(db)
    create_weekly_scopes_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new work_log and returns its ID' do
      person_id = person_service.insert(external_person_id: 'person-1', full_name: 'John Doe')
      params = {
        external_work_log_id: 'ext-log-1',
        duration_minutes: 90,
        creation_date: Time.now,
        person_id: person_id,
        started_at: Time.now
      }
      id = service.insert(params)
      log = service.find(id)
      expect(log[:external_work_log_id]).to eq('ext-log-1')
      expect(log[:duration_minutes]).to eq(90)
    end

    it 'assigns foreign keys using external ids' do
      person_id = person_service.insert(external_person_id: 'person-2', full_name: 'Jane')
      project_id = project_service.insert(external_project_id: 'proj-1', name: 'Project A', status: 'active')
      activity_id = activity_service.insert(external_activity_id: 'act-1', name: 'Analysis')
      work_item_id = work_item_service.insert(external_work_item_id: 'wi-1', name: 'Item A', status: 'todo')
      params = {
        external_work_log_id: 'ext-log-2',
        duration_minutes: 60,
        creation_date: Time.now,
        external_person_id: 'person-2',
        external_project_id: 'proj-1',
        external_activity_id: 'act-1',
        external_work_item_id: 'wi-1',
        started_at: Time.now
      }
      id = service.insert(params)
      log = service.find(id)
      expect(log[:person_id]).to eq(person_id)
      expect(log[:project_id]).to eq(project_id)
      expect(log[:activity_id]).to eq(activity_id)
      expect(log[:work_item_id]).to eq(work_item_id)
    end

    it 'accepts optional tags' do
      person_id = person_service.insert(external_person_id: 'person-3', full_name: 'With Tags')
      params = {
        external_work_log_id: 'ext-log-3',
        duration_minutes: 120,
        creation_date: Time.now,
        tags: JSON.generate(%w[urgent backend]),
        person_id: person_id,
        started_at: Time.now
      }
      id = service.insert(params)
      log = service.find(id)
      expect(log[:tags]).to include('urgent', 'backend')
    end
  end

  describe '#update' do
    it 'updates duration_minutes and tags' do
      person_id = person_service.insert(external_person_id: 'person-4', full_name: 'Updater')
      id = service.insert(
        external_work_log_id: 'ext-log-4',
        duration_minutes: 45,
        creation_date: Time.now,
        tags: JSON.generate(%w[init]),
        person_id: person_id,
        started_at: Time.now
      )
      service.update(id, duration_minutes: 75, tags: JSON.generate(%w[revised important]))
      log = service.find(id)
      expect(log[:duration_minutes]).to eq(75)
      expect(log[:tags]).to include('revised', 'important')
    end
  end

  describe '#delete' do
    it 'removes a work_log' do
      person_id = person_service.insert(external_person_id: 'person-5', full_name: 'Deleter')
      id = service.insert(
        external_work_log_id: 'ext-log-5',
        duration_minutes: 30,
        creation_date: Time.now,
        person_id: person_id,
        started_at: Time.now
      )
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
    end
  end

  describe '#find' do
    it 'retrieves a work_log by id' do
      person_id = person_service.insert(external_person_id: 'person-6', full_name: 'Finder')
      id = service.insert(
        external_work_log_id: 'ext-log-6',
        duration_minutes: 100,
        creation_date: Time.now,
        person_id: person_id,
        started_at: Time.now
      )
      log = service.find(id)
      expect(log[:external_work_log_id]).to eq('ext-log-6')
    end
  end

  describe '#query' do
    it 'returns logs with matching duration' do
      person_id = person_service.insert(external_person_id: 'person-7', full_name: 'Query')
      service.insert(
        external_work_log_id: 'ext-log-7',
        duration_minutes: 20,
        creation_date: Time.now,
        person_id: person_id,
        started_at: Time.now
      )
      results = service.query(duration_minutes: 20)
      expect(results.size).to be >= 1
    end
  end
end
