# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/weekly_scope'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::WeeklyScope do
  include TestDBHelpers

  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) do
    {
      adapter: 'sqlite',
      database: ':memory:'
    }
  end
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }
  let(:start_week_date) { Date.new(2024, 6, 13) }
  let(:end_week_date) { Date.new(2024, 6, 19) }
  let(:params) do
    { external_weekly_scope_id: 'ws-1', description: 'engineering-week-1', start_week_date:, end_week_date: }
  end

  # Create the table structure before each test
  before(:each) do
    db.drop_table?(:domains)
    db.drop_table?(:persons)
    db.drop_table?(:weekly_scopes)

    create_domains_table(db)
    create_persons_table(db)
    create_weekly_scopes_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new weekly scope and returns its ID' do
      id = service.insert(params)
      weekly_scope = service.find(id)

      expect(weekly_scope[:external_weekly_scope_id]).to eq('ws-1')
      expect(weekly_scope[:description]).to eq('engineering-week-1')
      expect(weekly_scope[:start_week_date]).to eq(start_week_date.to_time)
      expect(weekly_scope[:end_week_date]).to eq(end_week_date.to_time)
    end

    it 'assigns all foreign keys when given their external ids' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Dom1')
      person_id = person_service.insert(external_person_id: 'per-1', full_name: 'Person1')
      params = {
        external_weekly_scope_id: 'ext-ws-2',
        description: 'WeeklyScope with FKs',
        start_week_date: start_week_date,
        end_week_date: end_week_date,
        external_domain_id: 'dom-1',
        external_person_id: 'per-1'
      }
      id = service.insert(params)
      weekly_scope = service.find(id)
      expect(weekly_scope[:domain_id]).to eq(domain_id)
      expect(weekly_scope[:person_id]).to eq(person_id)
    end

    it 'removes all external ids from params even if nil' do
      params = {
        external_weekly_scope_id: 'ext-ws-3',
        description: 'WeeklyScope with FKs',
        start_week_date: start_week_date,
        end_week_date: end_week_date,
        external_domain_id: nil,
        external_person_id: nil
      }
      id = service.insert(params)
      weekly_scope = service.find(id)
      expect(weekly_scope).not_to have_key(:external_domain_id)
      expect(weekly_scope).not_to have_key(:external_person_id)
      expect(weekly_scope[:domain_id]).to be_nil
      expect(weekly_scope[:person_id]).to be_nil
    end
  end

  describe '#update' do
    it 'updates an weekly scope by ID' do
      id = service.insert(params)
      service.update(id, { description: 'Updated Description' })
      updated = service.find(id)

      expect(updated[:external_weekly_scope_id]).to eq('ws-1')
      expect(updated[:description]).to eq('Updated Description')
      expect(updated[:start_week_date]).to eq(start_week_date.to_time)
      expect(updated[:end_week_date]).to eq(end_week_date.to_time)
    end

    it 'reassigns foreign keys on update with external ids' do
      domain = domain_service.insert(external_domain_id: 'domain-2', name: 'domain2', archived: false)
      id = service.insert(
        external_weekly_scope_id: 'ext-ws-5',
        description: 'WeeklyScope with FKs',
        start_week_date: start_week_date,
        end_week_date: end_week_date,
        external_domain_id: 'domain-1'
      )
      service.update(id, { external_domain_id: 'domain-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(description: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a weekly scope by ID' do
      id = service.insert(params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a weekly scope by ID' do
      id = service.insert(params)
      found = service.find(id)

      expect(found[:external_weekly_scope_id]).to eq('ws-1')
      expect(found[:description]).to eq('engineering-week-1')
      expect(found[:start_week_date]).to eq(start_week_date.to_time)
      expect(found[:end_week_date]).to eq(end_week_date.to_time)
    end
  end

  describe '#query' do
    it 'queries weekly scope by condition' do
      id = service.insert(params)
      results = service.query(external_weekly_scope_id: 'ws-1')

      expect(results.map { |a| a[:id] }).to include(id)
      expect(results.first[:external_weekly_scope_id]).to eq('ws-1')
    end

    it 'returns all weekly scope with empty conditions' do
      count = service.query.size
      service.insert(params)

      expect(service.query.size).to eq(count + 1)
    end
  end
end
