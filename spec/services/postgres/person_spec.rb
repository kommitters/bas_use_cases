# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/person'
require_relative '../../../src/services/postgres/domain'

RSpec.describe Services::Postgres::Person do
  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:domain_service) { Services::Postgres::Domain.new(config) }

  before(:each) do
    db.drop_table?(:persons)
    db.drop_table?(:domains)
    db.create_table(:domains) do
      primary_key :id
      String :external_domain_id, null: false
      String :name, null: false
      DateTime :created_at
      DateTime :updated_at
    end
    db.create_table(:persons) do
      primary_key :id
      String :external_person_id, null: false
      String :name, null: false
      Integer :domain_id
      DateTime :created_at
      DateTime :updated_at
    end

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new person and returns its ID' do
      params = {
        external_person_id: 'ext-p-1',
        name: 'Jane Doe'
      }
      id = service.insert(params)
      person = service.find(id)
      expect(person[:name]).to eq('Jane Doe')
      expect(person[:external_person_id]).to eq('ext-p-1')
    end

    it 'assigns domain_id when given external_domain_id' do
      domain_id = domain_service.insert(external_domain_id: 'dom-1', name: 'Domain1')
      params = {
        external_person_id: 'ext-p-2',
        name: 'With Domain',
        external_domain_id: 'dom-1'
      }
      id = service.insert(params)
      person = service.find(id)
      expect(person[:domain_id]).to eq(domain_id)
    end

    it 'removes external_domain_id if it is present and nil' do
      params = {
        external_person_id: 'ext-p-3',
        name: 'Nil Domain',
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
      id = service.insert(external_person_id: 'ext-p-4', name: 'Old Name')
      service.update(id, { name: 'Updated Name' })
      updated = service.find(id)
      expect(updated[:name]).to eq('Updated Name')
      expect(updated[:external_person_id]).to eq('ext-p-4')
    end

    it 'reassigns domain_id on update with external_domain_id' do
      domain2 = domain_service.insert(external_domain_id: 'dom-2', name: 'Domain2')
      id = service.insert(
        external_person_id: 'ext-p-5',
        name: 'To Update Domain',
        external_domain_id: 'dom-1'
      )
      service.update(id, { external_domain_id: 'dom-2' })
      updated = service.find(id)
      expect(updated[:domain_id]).to eq(domain2)
    end

    it 'raises error if no ID is provided' do
      expect { service.update(nil, name: 'No ID') }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a person by ID' do
      id = service.insert(external_person_id: 'ext-p-6', name: 'To Delete')
      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a person by ID' do
      id = service.insert(external_person_id: 'ext-p-7', name: 'Find Me')
      found = service.find(id)
      expect(found[:name]).to eq('Find Me')
      expect(found[:external_person_id]).to eq('ext-p-7')
    end
  end

  describe '#query' do
    it 'queries persons by condition' do
      id = service.insert(external_person_id: 'ext-p-8', name: 'Query Me')
      results = service.query(name: 'Query Me')
      expect(results.map { |p| p[:id] }).to include(id)
      expect(results.first[:external_person_id]).to eq('ext-p-8')
    end

    it 'returns all persons with empty conditions' do
      count = service.query.size
      service.insert(external_person_id: 'ext-p-9', name: 'Another')
      expect(service.query.size).to eq(count + 1)
    end
  end
end
