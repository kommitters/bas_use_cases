# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/key_result'
require_relative '../../../src/services/postgres/activities_key_results'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::ActivitiesKeyResults do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:key_result_service) { Services::Postgres::KeyResult.new(config) }
  let(:activity_key_result_service) { described_class.new(config) }

  let(:key_result_params) do
    {
      external_key_result_id: 'kr-uuid-123',
      okr: 'Improve user experience',
      key_result: 'Faster page loads',
      metric: 100,
      current: 20,
      progress: 20,
      period: 'Q3',
      objective: 'UX over performance'
    }
  end

  let(:activity_id) { 1 }

  before(:each) do
    db.drop_table?(:activities_key_results)
    db.drop_table?(:key_results)
    db.drop_table?(:activities)

    create_key_results_table(db)
    create_activities_table(db)
    create_activities_key_results_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    # Insert dummy activity
    db[:activities].insert(name: 'Refactor dashboard', external_activity_id: 'abc-123')
  end

  describe '#insert' do
    it 'inserts a relation by resolving external_key_result_id to key_result_id' do
      key_result_id = key_result_service.insert(key_result_params)

      relation_params = {
        activity_id: activity_id,
        external_key_result_id: key_result_params[:external_key_result_id]
      }

      id = activity_key_result_service.insert(relation_params)
      record = activity_key_result_service.find(id)

      expect(record[:activity_id]).to eq(activity_id)
      expect(record[:key_result_id]).to eq(key_result_id)
    end
  end

  describe '#update' do
    it 'updates the relation and resolves new external_key_result_id' do
      id = activity_key_result_service.insert({
                                                activity_id: activity_id,
                                                external_key_result_id: key_result_params[:external_key_result_id]
                                              })

      new_kr_id = key_result_service.insert(key_result_params.merge(
                                              external_key_result_id: 'kr-uuid-999',
                                              key_result: 'Improve loading spinner'
                                            ))

      activity_key_result_service.update(id, { external_key_result_id: 'kr-uuid-999' })
      updated = activity_key_result_service.find(id)

      expect(updated[:key_result_id]).to eq(new_kr_id)
    end
  end

  describe '#delete' do
    it 'deletes the relation' do
      key_result_service.insert(key_result_params)

      id = activity_key_result_service.insert({
                                                activity_id: activity_id,
                                                external_key_result_id: key_result_params[:external_key_result_id]
                                              })

      expect { activity_key_result_service.delete(id) }.to change {
        activity_key_result_service.query.size
      }.by(-1)
    end
  end

  describe '#find' do
    it 'finds the relation by ID' do
      kr_id = key_result_service.insert(key_result_params)

      id = activity_key_result_service.insert({
                                                activity_id: activity_id,
                                                external_key_result_id: key_result_params[:external_key_result_id]
                                              })

      record = activity_key_result_service.find(id)

      expect(record).not_to be_nil
      expect(record[:activity_id]).to eq(activity_id)
      expect(record[:key_result_id]).to eq(kr_id)
    end
  end

  describe '#query' do
    it 'returns relations matching the given activity_id' do
      key_result_service.insert(key_result_params)

      activity_key_result_service.insert({
                                           activity_id: activity_id,
                                           external_key_result_id: key_result_params[:external_key_result_id]
                                         })

      results = activity_key_result_service.query(activity_id: activity_id)

      expect(results.size).to eq(1)
      expect(results.first[:activity_id]).to eq(activity_id)
    end
  end
end
