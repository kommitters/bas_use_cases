# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'json'
require 'date'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_issue'
require_relative '../../../src/services/postgres/apex_people'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubIssue do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }

  # We use real ApexPeople to simulate relation lookups if necessary,
  # although for setup we will use direct insertion to avoid complex dependencies.
  let(:apex_people_service) { Services::Postgres::ApexPeople.new(config) }

  before(:each) do
    # Connection mock
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    # Cleanup (reverse order)
    db.drop_table?(:github_issues_history)
    db.drop_table?(:github_issues)
    db.drop_table?(:apex_people)
    db.drop_table?(:organizational_units)

    # Creation
    create_organizational_units_table(db)
    create_apex_people_table(db)
    create_github_issues_table(db)
    create_github_issues_history_table(db)

    # Seed: Insert a person directly to have someone to relate to
    @person_id = db[:apex_people].insert(
      external_person_id: 'person-uuid-1',
      full_name: 'Dev One',
      github_username: 'dev_one_gh',
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe '#insert' do
    it 'creates a new github_issue and returns its ID' do
      params = {
        external_github_issue_id: 1001,
        title: 'Fix login bug',
        number: 1,
        repository_id: 50,
        status: 'open',
        github_username: 'dev_one_gh' # Test relation resolution
      }

      id = service.insert(params)
      issue = service.find(id)

      expect(issue).not_to be_nil
      expect(issue[:external_github_issue_id]).to eq(1001)
      expect(issue[:title]).to eq('Fix login bug')
      # Verify that github_username resolved to the correct person_id
      expect(issue[:person_id]).to eq(@person_id)
    end

    it 'handles array fields for labels and assignees correctly' do
      labels_json = JSON.generate(%w[bug urgent])
      assignees_json = JSON.generate(%w[dev_one_gh dev_two_gh])

      params = {
        external_github_issue_id: 1002,
        title: 'Complex Issue',
        repository_id: 50,
        labels: labels_json,
        assignees: assignees_json
      }

      id = service.insert(params)
      issue = service.find(id)

      expect(issue[:labels]).to eq(labels_json)
      expect(issue[:assignees]).to eq(assignees_json)
    end
  end

  describe '#update' do
    let!(:issue_id) do
      service.insert(
        external_github_issue_id: 2001,
        title: 'Original Title',
        repository_id: 99,
        status: 'open',
        github_username: 'dev_one_gh'
      )
    end

    it 'updates a github_issue by its ID' do
      service.update(issue_id, { title: 'Updated Title', status: 'closed' })
      updated_issue = service.find(issue_id)

      expect(updated_issue[:title]).to eq('Updated Title')
      expect(updated_issue[:status]).to eq('closed')
    end

    it 'reassigns foreign keys on update via github_username' do
      # Create another person
      other_person_id = db[:apex_people].insert(
        external_person_id: 'person-uuid-2',
        full_name: 'Dev Two',
        github_username: 'dev_two_gh'
      )

      # Update the issue assigning it to the new GitHub user
      service.update(issue_id, { github_username: 'dev_two_gh' })
      updated_issue = service.find(issue_id)

      expect(updated_issue[:person_id]).to eq(other_person_id)
    end

    it 'saves the previous state to the history table before updating' do
      expect(db[:github_issues_history].where(issue_id: issue_id).all).to be_empty

      update_params = { title: 'New History Title', status: 'closed' }
      service.update(issue_id, update_params)

      # Verify current change
      updated_record = service.find(issue_id)
      expect(updated_record[:title]).to eq('New History Title')

      # Verify history
      history_records = db[:github_issues_history].where(issue_id: issue_id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:issue_id]).to eq(issue_id)
      expect(historical_record[:title]).to eq('Original Title')
      expect(historical_record[:status]).to eq('open')
      expect(historical_record[:person_id]).to eq(@person_id)
    end

    it 'raises an ArgumentError if no ID is provided' do
      # Mock handle_error to suppress logging noise during this specific test
      allow(service).to receive(:handle_error) { |e| raise e }

      expect do
        service.update(nil, { status: 'closed' })
      end.to raise_error(ArgumentError, /GithubIssue id is required/)
    end
  end

  describe '#delete' do
    it 'deletes a github_issue by ID' do
      id_to_delete = service.insert(
        external_github_issue_id: 3001,
        title: 'To Delete',
        repository_id: 10
      )

      expect { service.delete(id_to_delete) }.to change { service.query.size }.by(-1)
      expect(service.find(id_to_delete)).to be_nil
    end
  end

  describe '#query' do
    before do
      service.insert(
        external_github_issue_id: 4001,
        title: 'Query Me',
        repository_id: 500,
        milestone_id: 12
      )
    end

    it 'queries github_issues by a specific condition' do
      results = service.query(repository_id: 500)
      expect(results.size).to eq(1)
      expect(results.first[:title]).to eq('Query Me')
    end

    it 'returns empty array if no match found' do
      results = service.query(repository_id: 99_999)
      expect(results).to be_empty
    end
  end
end
