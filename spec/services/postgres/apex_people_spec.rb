# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'date'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/apex_people'
require_relative '../../../src/services/postgres/organizational_unit'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::ApexPeople do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }
  let(:org_unit_service) { Services::Postgres::OrganizationalUnit.new(config) }

  let(:org_unit_id) { @org_unit_id }

  let(:valid_params) do
    {
      external_person_id: 'person-uuid-001',
      full_name: 'John Doe',
      email_address: 'john.doe@example.com',
      is_active: true,
      hire_date: Date.today - 365,
      github_username: 'johndoe',
      role: 'Developer',
      job_title: 'Backend Engineer',
      external_org_unit_id: 'org-uuid-101'
    }
  end

  before(:each) do
    db.drop_table?(:apex_people_history)
    db.drop_table?(:apex_people)
    db.drop_table?(:organizational_units)

    create_organizational_units_table(db)
    create_apex_people_table(db)
    create_apex_people_history_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    @org_unit_id = org_unit_service.insert(
      external_org_unit_id: 'org-uuid-101',
      name: 'Engineering',
      status: 'active'
    )
  end

  describe '#insert' do
    context 'with valid params' do
      it 'creates a new person and resolves the org_unit_id relation' do
        id = service.insert(valid_params)
        person = service.find(id)

        expect(person).not_to be_nil
        expect(person[:external_person_id]).to eq(valid_params[:external_person_id])
        expect(person[:full_name]).to eq('John Doe')
        expect(person[:email_address]).to eq('john.doe@example.com')

        expect(person[:org_unit_id]).to eq(org_unit_id)
      end
    end

    context 'with missing required param' do
      it 'raises an error' do
        invalid_params = valid_params.dup.tap { |h| h.delete(:external_person_id) }
        expect { service.insert(invalid_params) }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe '#update' do
    context 'with valid ID' do
      it 'updates person details' do
        id = service.insert(valid_params)
        service.update(id, job_title: 'Senior Backend Engineer')
        updated = service.find(id)

        expect(updated[:job_title]).to eq('Senior Backend Engineer')
      end

      it 'reassigns org_unit_id on update with external_org_unit_id' do
        org_unit_service.insert(external_org_unit_id: 'org-uuid-202', name: 'Product', status: 'active')
        new_org_unit_record = org_unit_service.query(external_org_unit_id: 'org-uuid-202').first

        id = service.insert(valid_params)

        service.update(id, external_org_unit_id: 'org-uuid-202')
        updated = service.find(id)

        expect(updated[:org_unit_id]).to eq(new_org_unit_record[:id])
      end

      it 'saves the previous state to the history table before updating' do
        initial_params = valid_params.merge(job_title: 'Junior Dev', is_active: true)
        id = service.insert(initial_params)

        expect(db[:apex_people_history].where(person_id: id).all).to be_empty

        update_params = { job_title: 'Mid Dev', is_active: false }
        service.update(id, update_params)

        updated_record = service.find(id)
        expect(updated_record[:job_title]).to eq('Mid Dev')
        expect(updated_record[:is_active]).to eq(false)

        history_records = db[:apex_people_history].where(person_id: id).all
        expect(history_records.size).to eq(1)

        historical_record = history_records.first
        expect(historical_record[:person_id]).to eq(id)
        expect(historical_record[:job_title]).to eq('Junior Dev')
        expect(historical_record[:is_active]).to eq(true)
      end
    end

    context 'without ID' do
      it 'raises an ArgumentError' do
        expect { service.update(nil, full_name: 'Ghost') }.to raise_error(ArgumentError, /Person id is required/)
      end
    end
  end

  describe '#delete' do
    it 'removes a person by ID' do
      id = service.insert(valid_params)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'retrieves a person by ID' do
      id = service.insert(valid_params)
      found = service.find(id)

      expect(found).not_to be_nil
      expect(found[:github_username]).to eq(valid_params[:github_username])
    end
  end

  describe '#query' do
    context 'with filters' do
      it 'returns filtered results' do
        id = service.insert(valid_params)
        results = service.query(external_person_id: valid_params[:external_person_id])

        expect(results).not_to be_empty
        expect(results.map { |r| r[:id] }).to include(id)
      end
    end

    context 'without filters' do
      it 'returns all results' do
        initial_count = service.query.size
        service.insert(valid_params)

        expect(service.query.size).to eq(initial_count + 1)
      end
    end
  end
end
