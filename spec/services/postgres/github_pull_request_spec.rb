# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'securerandom'
require 'json'
require 'date'

require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_pull_request'
require_relative '../../../src/services/postgres/github_release'
require_relative '../../../src/services/postgres/github_issue'
require_relative '../../../src/services/postgres/apex_people'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubPullRequest do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }

  # Dependencies
  let(:release_service) { Services::Postgres::GithubRelease.new(config) }
  let(:issue_service) { Services::Postgres::GithubIssue.new(config) }
  let(:person_service) { Services::Postgres::ApexPeople.new(config) }

  before(:each) do
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    db.drop_table?(:github_pull_requests_history)
    db.drop_table?(:github_pull_requests)
    db.drop_table?(:github_issues)
    db.drop_table?(:github_releases)
    db.drop_table?(:apex_people)
    db.drop_table?(:organizational_units)

    create_organizational_units_table(db)
    create_apex_people_table(db)
    create_github_issues_table(db)
    create_github_releases_table(db)
    create_github_pull_requests_table(db)
    create_github_pull_requests_history_table(db)

    @person_id = db[:apex_people].insert(external_person_id: 'person-1', full_name: 'Test User', created_at: Time.now,
                                         updated_at: Time.now)

    @release_id = db[:github_releases].insert(
      name: 'Release 1',
      external_github_release_id: 900,
      repository_id: 1,
      tag_name: 'v1.0-test',
      created_at: Time.now,
      updated_at: Time.now,
      published_timestamp: Time.now
    )

    @issue_id = db[:github_issues].insert(
      external_github_issue_id: 123,
      repository_id: 1,
      person_id: @person_id,
      number: 123,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe '#insert' do
    it 'creates a new pull request and returns its ID' do
      params = {
        external_github_pull_request_id: 1,
        repository_id: 100,
        title: 'My First PR',
        creation_date: Time.now
      }
      id = service.insert(params)
      pr = service.find(id)

      expect(pr).not_to be_nil
      expect(pr[:external_github_pull_request_id]).to eq(1)
      expect(pr[:title]).to eq('My First PR')
    end

    it 'assigns foreign keys for release and issue using external ids' do
      params = {
        external_github_pull_request_id: 2,
        repository_id: 1,
        title: 'PR with Relations',
        creation_date: Time.now,
        external_github_release_id: 900,
        number: 123
      }

      id = service.insert(params)
      pr = service.find(id)

      expect(pr[:release_id]).to eq(@release_id)
      expect(pr[:issue_id]).to eq(@issue_id)
    end

    it 'handles array and json fields' do
      params = {
        external_github_pull_request_id: 3,
        repository_id: 1,
        title: 'PR with Data',
        creation_date: Time.now,
        related_issue_ids: JSON.generate([10, 20]),
        reviews_data: JSON.generate({ state: 'APPROVED', user: 'test-user' })
      }
      id = service.insert(params)
      pr = service.find(id)

      expect(pr[:related_issue_ids]).to eq('[10,20]')
      expect(pr[:reviews_data]).to eq('{"state":"APPROVED","user":"test-user"}')
    end
  end

  describe '#update' do
    let!(:pr_id) do
      service.insert(
        external_github_pull_request_id: 4,
        repository_id: 1,
        title: 'Initial Title',
        creation_date: Time.now,
        external_github_release_id: 900
      )
    end

    it 'updates a pull request by its ID' do
      service.update(pr_id, { title: 'Updated Title', merge_date: Time.now })
      updated_pr = service.find(pr_id)

      expect(updated_pr[:title]).to eq('Updated Title')
      expect(updated_pr[:merge_date]).not_to be_nil
    end

    it 'reassigns foreign keys on update' do
      # Create a new issue to reassign to
      new_issue_id = db[:github_issues].insert(
        external_github_issue_id: 456,
        repository_id: 1,
        person_id: @person_id,
        created_at: Time.now,
        updated_at: Time.now,
        number: 456
      )

      service.update(pr_id, { number: 456 })
      updated_pr = service.find(pr_id)

      expect(updated_pr[:issue_id]).to eq(new_issue_id)
    end

    it 'saves the previous state to the history table before updating' do
      expect(db[:github_pull_requests_history].where(pull_request_id: pr_id).all).to be_empty

      service.update(pr_id, { title: 'Updated Title', merge_date: Time.now })

      updated_record = service.find(pr_id)
      expect(updated_record[:title]).to eq('Updated Title')
      expect(updated_record[:merge_date]).not_to be_nil

      history_records = db[:github_pull_requests_history].where(pull_request_id: pr_id).all
      expect(history_records.size).to eq(1)

      historical_record = history_records.first
      expect(historical_record[:pull_request_id]).to eq(pr_id)
      expect(historical_record[:title]).to eq('Initial Title')
      expect(historical_record[:merge_date]).to be_nil
    end

    it 'raises an ArgumentError if no ID is provided' do
      # Suppress logging
      allow(service).to receive(:handle_error) { |e| raise e }

      expect { service.update(nil, { title: 'No ID' }) }
        .to raise_error(ArgumentError, 'GithubPullRequest id is required to update')
    end
  end

  describe '#delete' do
    it 'deletes a pull request by ID' do
      id_to_delete = service.insert(
        external_github_pull_request_id: 5,
        repository_id: 1,
        title: 'To Be Deleted',
        creation_date: Time.now
      )
      expect { service.delete(id_to_delete) }.to change { service.query.size }.by(-1)
      expect(service.find(id_to_delete)).to be_nil
    end
  end

  describe '#query' do
    it 'queries pull requests by a specific condition' do
      service.insert(
        external_github_pull_request_id: 6,
        repository_id: 999,
        title: 'Find Me',
        creation_date: Time.now
      )
      results = service.query(repository_id: 999)
      expect(results.size).to eq(1)
      expect(results.first[:title]).to eq('Find Me')
    end
  end
end
