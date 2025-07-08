# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'securerandom'
require 'json'

require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_pull_request'
require_relative '../../../src/services/postgres/github_release'
require_relative '../../../src/services/postgres/github_issue'
require_relative '../../../src/services/postgres/person'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubPullRequest do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }
  let(:release_service) { Services::Postgres::GithubRelease.new(config) }
  let(:issue_service) { Services::Postgres::GithubIssue.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }

  before(:each) do
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    db.drop_table?(:github_pull_requests)
    db.drop_table?(:github_releases)
    db.drop_table?(:github_issues)
    db.drop_table?(:persons)

    create_persons_table(db)
    create_github_issues_table(db)
    create_github_releases_table(db)
    create_github_pull_requests_table(db)

    @person_id = person_service.insert(external_person_id: 'person-1', full_name: 'Test User')
    @release_id = release_service.insert(external_github_release_id: 'ghr-1', repository_id: 1, tag_name: 'v1.0',
                                         creation_timestamp: Time.now)
    @issue_id = issue_service.insert(external_github_issue_id: 'issue-1', repository_id: 1, person_id: @person_id)
  end

  describe '#insert' do
    it 'creates a new pull request and returns its ID' do
      params = {
        external_github_pull_request_id: 'pr-1',
        repository_id: 123,
        title: 'My First PR',
        creation_date: Time.now
      }
      id = service.insert(params)
      pr = service.find(id)

      expect(pr).not_to be_nil
      expect(pr[:external_github_pull_request_id]).to eq('pr-1')
      expect(pr[:title]).to eq('My First PR')
    end

    it 'assigns foreign keys for release and issue using external ids' do
      params = {
        external_github_pull_request_id: 'pr-2',
        repository_id: 1,
        title: 'PR with Relations',
        creation_date: Time.now,
        external_release_id: 'ghr-1',
        external_issue_id: 'issue-1'
      }
      id = service.insert(params)
      pr = service.find(id)

      expect(pr[:release_id]).to eq(@release_id)
      expect(pr[:issue_id]).to eq(@issue_id)
    end

    it 'handles array and json fields' do
      params = {
        external_github_pull_request_id: 'pr-3',
        repository_id: 1,
        title: 'PR with Data',
        creation_date: Time.now,
        related_issue_ids: JSON.generate([10, 20, 30]),
        reviews_data: JSON.generate({ state: 'APPROVED', user: 'test-user' })
      }
      id = service.insert(params)
      pr = service.find(id)

      expect(pr[:related_issue_ids]).to eq('[10,20,30]')
      expect(pr[:reviews_data]).to eq('{"state":"APPROVED","user":"test-user"}')
    end
  end

  describe '#update' do
    let!(:pr_id) do
      service.insert(
        external_github_pull_request_id: 'pr-4',
        repository_id: 1,
        title: 'Initial Title',
        creation_date: Time.now
      )
    end

    it 'updates a pull request by its ID' do
      update_params = {
        title: 'Updated Title',
        merge_date: Time.now
      }
      service.update(pr_id, update_params)
      updated_pr = service.find(pr_id)

      expect(updated_pr[:title]).to eq('Updated Title')
      expect(updated_pr[:merge_date]).not_to be_nil
    end

    it 'reassigns foreign keys on update' do
      new_issue_id = issue_service.insert(external_github_issue_id: 'issue-2', repository_id: 1, person_id: @person_id)
      service.update(pr_id, { external_issue_id: 'issue-2' })
      updated_pr = service.find(pr_id)

      expect(updated_pr[:issue_id]).to eq(new_issue_id)
    end

    it 'raises an ArgumentError if no ID is provided' do
      allow($stdout).to receive(:write)
      expect do
        service.update(nil, { title: 'No ID' })
      end.to raise_error(ArgumentError, 'GithubPullRequest id is required to update')
    end
  end

  describe '#delete' do
    it 'deletes a pull request by ID' do
      id_to_delete = service.insert(
        external_github_pull_request_id: 'pr-5',
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
        external_github_pull_request_id: 'pr-6',
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
