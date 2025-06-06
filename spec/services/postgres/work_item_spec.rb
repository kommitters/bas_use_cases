# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/work_item'

RSpec.describe Services::Postgres::WorkItem do
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }

  before(:each) do
    db.drop_table?(:work_items)
    db.drop_table?(:activities)
    db.drop_table?(:projects)
    db.create_table(:activities) do
      primary_key :id
      String :external_activity_id, null: false
    end
    db.create_table(:projects) do
      primary_key :id
      String :external_project_id, null: false
    end
    db.create_table(:work_items) do
      primary_key :id
      String :external_work_item_id, null: false
      Integer :project_id
      Integer :activity_id
      String :assignee_person_id
      String :external_domain_id
      String :external_weekly_scope_id
      String :work_item_status, size: 50, null: false
      DateTime :work_item_completion_date
      DateTime :created_at
      DateTime :updated_at
    end
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  let!(:activity) { db[:activities].insert(external_activity_id: 'EXT-ACT-1') }
  let!(:project) { db[:projects].insert(external_project_id: 'EXT-PROJ-1') }

  describe '#insert' do
    it 'creates a new work item and returns its ID' do
      params = {
        external_work_item_id: 'ext-wi-1',
        work_item_status: 'open'
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item[:external_work_item_id]).to eq('ext-wi-1')
      expect(work_item[:work_item_status]).to eq('open')
    end
  end

  describe '#insert with external keys' do
    it 'resolves external_activity_id and sets activity_id' do
      params = {
        external_work_item_id: 'wi-1',
        work_item_status: 'open',
        external_activity_id: 'EXT-ACT-1'
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item[:activity_id]).to eq(activity)
    end

    it 'resolves external_project_id and sets project_id' do
      params = {
        external_work_item_id: 'wi-2',
        work_item_status: 'open',
        external_project_id: 'EXT-PROJ-1'
      }
      id = service.insert(params)
      work_item = service.find(id)
      expect(work_item[:project_id]).to eq(project)
    end

    it 'raises error for unknown external_activity_id' do
      expect do
        service.insert(
          external_work_item_id: 'wi-3',
          work_item_status: 'open',
          external_activity_id: 'NOT-FOUND'
        )
      end.to raise_error(/activities not found/)
    end
  end

  describe '#update' do
    it 'updates a work item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-2', work_item_status: 'open')
      service.update(id, { work_item_status: 'closed' })
      updated = service.find(id)
      expect(updated[:work_item_status]).to eq('closed')
      expect(updated[:external_work_item_id]).to eq('ext-wi-2')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, { work_item_status: 'no-id' }) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a work item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-3', work_item_status: 'open')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a work item by ID' do
      id = service.insert(external_work_item_id: 'ext-wi-4', work_item_status: 'review')
      found = service.find(id)
      expect(found[:work_item_status]).to eq('review')
      expect(found[:external_work_item_id]).to eq('ext-wi-4')
    end
  end

  describe '#query' do
    it 'queries work items by condition' do
      id = service.insert(external_work_item_id: 'ext-wi-5', work_item_status: 'blocked')
      results = service.query(work_item_status: 'blocked')
      expect(results.map { |w| w[:id] }).to include(id)
      expect(results.first[:external_work_item_id]).to eq('ext-wi-5')
    end

    it 'returns all work items with empty conditions' do
      count = service.query.size
      service.insert(external_work_item_id: 'ext-wi-6', work_item_status: 'open')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
