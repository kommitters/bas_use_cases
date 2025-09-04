# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'securerandom'
require 'json'

require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_issue'
require_relative '../../../src/services/postgres/person'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubIssue do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }

  before(:each) do
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    db.drop_table?(:github_issues_history)
    db.drop_table?(:github_issues)
    db.drop_table?(:persons)
    db.drop_table?(:domains)

    create_persons_table(db)
    create_domains_table(db)
    create_github_issues_table(db)
    create_github_issues_history_table(db)

    @person_id = person_service.insert(external_person_id: 'person-123', full_name: 'Test Person')
  end

  describe '#insert' do
    it 'creates a new github_issue and returns its ID' do
      params = {
        external_github_issue_id: 1,
        repository_id: 100,
        external_person_id: 'person-123'
      }
      id = service.insert(params)
      issue = service.find(id)

      expect(issue).not_to be_nil
      expect(issue[:external_github_issue_id]).to eq(1)
      expect(issue[:repository_id]).to eq(100)
    end

    it 'assigns the person_id foreign key from the external id' do
      params = {
        external_github_issue_id: 2,
        repository_id: 101,
        external_person_id: 'person-123'
      }
      id = service.insert(params)
      issue = service.find(id)

      expect(issue[:person_id]).to eq(@person_id)
    end

    it 'handles array fields for labels and assignees' do
      params = {
        external_github_issue_id: 3,
        repository_id: 102,
        external_person_id: 'person-123',
        labels: JSON.generate(%w[bug critical]),
        assignees: JSON.generate(%w[user1 user2])
      }
      id = service.insert(params)
      issue = service.find(id)

      expect(issue[:labels]).to eq('["bug","critical"]')
      expect(issue[:assignees]).to eq('["user1","user2"]')
    end
  end

  describe '#update' do
    let!(:issue_id) do
      service.insert(
        external_github_issue_id: 4,
        repository_id: 200,
        external_person_id: 'person-123',
        labels: JSON.generate(%w[issue initial])
      )
    end

    it 'updates a github_issue by its ID' do
      service.update(issue_id, { milestone_id: 50, labels: JSON.generate(['enhancement']) })
      updated_issue = service.find(issue_id)

      expect(updated_issue[:milestone_id]).to eq(50)
      expect(updated_issue[:labels]).to eq('["enhancement"]')
    end

    it 'reassigns foreign keys on update' do
      person2_id = person_service.insert(external_person_id: 'person-456', full_name: 'Another Person')
      service.update(issue_id, { external_person_id: 'person-456' })
      updated_issue = service.find(issue_id)

      expect(updated_issue[:person_id]).to eq(person2_id)
    end

    it 'saves the previous state to the history table before updating' do
      expect(db[:github_issues_history].where(issue_id: issue_id).all).to be_empty

      service.update(issue_id, { repository_id: 300, labels: JSON.generate(%w[bug critical]) })

      updated_record = service.find(issue_id)
      expect(updated_record[:repository_id]).to eq(300)
      expect(updated_record[:labels]).to eq('["bug","critical"]')

      history_records = db[:github_issues_history].where(issue_id: issue_id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:issue_id]).to eq(issue_id)

      expect(historical_record[:repository_id]).to eq(200)
      expect(historical_record[:labels]).to eq('["issue","initial"]')
    end

    it 'raises an ArgumentError if no ID is provided' do
      allow($stdout).to receive(:write)
      expect do
        service.update(nil, { milestone_id: 99 })
      end.to raise_error(ArgumentError, 'GithubIssue id is required to update')
    end
  end

  describe '#delete' do
    it 'deletes a github_issue by ID' do
      id_to_delete = service.insert(
        external_github_issue_id: 5,
        repository_id: 300,
        external_person_id: 'person-123'
      )

      expect { service.delete(id_to_delete) }.to change { service.query.size }.by(-1)
      expect(service.find(id_to_delete)).to be_nil
    end
  end

  describe '#query' do
    before do
      service.insert(
        external_github_issue_id: 6,
        repository_id: 400,
        milestone_id: 1,
        external_person_id: 'person-123'
      )
    end

    it 'queries github_issues by a specific condition' do
      results = service.query(repository_id: 400)
      expect(results.size).to eq(1)
      expect(results.first[:milestone_id]).to eq(1)
    end
  end
end
