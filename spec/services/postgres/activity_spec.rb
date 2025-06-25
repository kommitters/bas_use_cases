# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/activity'
require_relative '../../../src/services/postgres/domain'
require_relative '../../../src/services/postgres/key_result'
require_relative '../../../src/services/postgres/activities_key_results'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Activity do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end

  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }
  let(:key_results_service) { Services::Postgres::KeyResult.new(config) }
  let(:akr_service) { Services::Postgres::ActivitiesKeyResults.new(config) }

  before(:each) do
    db.drop_table?(:activities_key_results)
    db.drop_table?(:key_results)
    db.drop_table?(:activities)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_activities_table(db)
    create_key_results_table(db)
    create_activities_key_results_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
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

    it 'assigns domain_id when given external_domain_id' do
      domain_id = domain_service.insert(external_domain_id: 'ext-d-1', name: 'Domain1')
      params = {
        external_activity_id: 'ext-a-2',
        name: 'With Domain',
        external_domain_id: 'ext-d-1'
      }
      id = service.insert(params)
      activity = service.find(id)
      expect(activity[:domain_id]).to eq(domain_id)
    end

    it 'removes external_domain_id if it is present and nil' do
      params = {
        external_activity_id: 'ext-a-3',
        name: 'Nil Domain',
        external_domain_id: nil
      }
      id = service.insert(params)
      activity = service.find(id)
      expect(activity).not_to have_key(:external_domain_id)
      expect(activity[:domain_id]).to be_nil
    end

    it 'creates activity with related key_results using external_key_results_ids' do
      params = {
        external_activity_id: 'ext-a-10',
        name: 'With Key Results',
        external_key_results_ids: %w[kr1 kr2]
      }

      id = service.insert(params)
      activity = service.find(id)
      expect(activity[:external_activity_id]).to eq('ext-a-10')

      relations = akr_service.query(activity_id: id)
      expect(relations.size).to eq(2)
    end
  end

  describe '#update' do
    it 'updates an activity by ID' do
      id = service.insert(external_activity_id: 'ext-a-4', name: 'To Update')
      service.update(id, { name: 'Updated Activity' })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Activity')
      expect(updated[:external_activity_id]).to eq('ext-a-4')
    end

    it 'reassigns domain_id on update with external_domain_id' do
      domain_service.insert(external_domain_id: 'domain-1', name: 'Domain1')
      domain2 = domain_service.insert(external_domain_id: 'domain-2', name: 'Domain2')
      id = service.insert(external_activity_id: 'ext-a-5', name: 'To Reassign', external_domain_id: 'domain-1')
      service.update(id, { external_domain_id: 'domain-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain2)
    end

    it 'replaces key_results associations on update' do
      kr3 = key_results_service.insert(external_key_result_id: 'kr3', okr: 'Test', key_result: 'KR3', metric: 'x',
                                       current: 0, progress: 0, period: 'Q1', objective: 'Obj')

      id = service.insert(
        external_activity_id: 'ext-a-6',
        name: 'To Update Relations',
        external_key_results_ids: %w[kr1 kr2]
      )

      expect(akr_service.query(activity_id: id).size).to eq(2)

      service.update(id, { external_key_results_ids: ['kr3'] })
      expect(akr_service.query(activity_id: id).size).to eq(1)
      expect(akr_service.query(activity_id: id).first[:key_result_id]).to eq(kr3)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes an activity by ID and removes relations' do
      id = service.insert(external_activity_id: 'ext-a-6', name: 'To Delete', external_key_results_ids: ['kr-d'])

      expect { service.delete(id) }.to change { service.query(id: id).size }.by(-1)
      expect(service.find(id)).to be_nil
      expect(akr_service.query(activity_id: id)).to be_empty
    end
  end

  describe '#find' do
    it 'finds an activity by ID' do
      id = service.insert(external_activity_id: 'ext-a-7', name: 'Find Me')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_activity_id]).to eq('ext-a-7')
    end
  end

  describe '#query' do
    it 'queries activities by condition' do
      id = service.insert(external_activity_id: 'ext-a-8', name: 'Query Me')
      results = service.query(name: 'Query Me')
      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_activity_id]).to eq('ext-a-8')
    end

    it 'returns all activities with empty conditions' do
      count = service.query.size
      service.insert(external_activity_id: 'ext-a-9', name: 'Another')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
