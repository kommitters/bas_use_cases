# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/person'
require_relative '../../../src/services/postgres/domain'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::Person do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  before(:each) do
    db.drop_table?(:persons_history)
    db.drop_table?(:persons)
    db.drop_table?(:domains)

    create_persons_table(db)
    create_domains_table(db)
    create_persons_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new person and returns its ID' do
      params = {
        external_person_id: 'ext-p-1',
        full_name: 'Jane Doe'
      }
      id = service.insert(params)
      person = service.find(id)
      expect(person[:full_name]).to eq('Jane Doe')
      expect(person[:external_person_id]).to eq('ext-p-1')
    end

    it 'removes external_domain_id if it is present and nil' do
      params = {
        external_person_id: 'ext-p-3',
        full_name: 'Nil Domain',
        external_domain_id: nil
      }
      id = service.insert(params)
      person = service.find(id)
      expect(person).not_to have_key(:external_domain_id)
      expect(person[:domain_id]).to be_nil
    end
  end

  describe '#update' do
    it 'updates a person by ID' do
      id = service.insert(external_person_id: 'ext-p-4', full_name: 'Old Name')
      service.update(id, { full_name: 'Updated Name' })
      updated = service.find(id)
      expect(updated[:full_name]).to eq('Updated Name')
      expect(updated[:external_person_id]).to eq('ext-p-4')
    end

    it 'saves the previous state to the history table before updating' do
      id = service.insert(external_person_id: 'p-hist-1', full_name: 'Initial Name')

      expect(db[:persons_history].where(person_id: id).all).to be_empty

      service.update(id, { full_name: 'Updated Name' })

      updated_record = service.find(id)
      expect(updated_record[:full_name]).to eq('Updated Name')

      history_records = db[:persons_history].where(person_id: id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:person_id]).to eq(id)
      expect(historical_record[:full_name]).to eq('Initial Name')
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, full_name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a person by ID' do
      id = service.insert(external_person_id: 'ext-p-6', full_name: 'To Delete')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a person by ID' do
      id = service.insert(external_person_id: 'ext-p-7', full_name: 'Find Me')
      found = service.find(id)
      expect(found[:full_name]).to eq('Find Me')
      expect(found[:external_person_id]).to eq('ext-p-7')
    end
  end

  describe '#query' do
    it 'queries persons by condition' do
      id = service.insert(external_person_id: 'ext-p-8', full_name: 'Query Me')
      results = service.query(full_name: 'Query Me')
      expect(results.map { |p| p[:id] }).to include(id)
      expect(results.first[:external_person_id]).to eq('ext-p-8')
    end

    it 'returns all persons with empty conditions' do
      count = service.query.size
      service.insert(external_person_id: 'ext-p-9', full_name: 'Another')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
