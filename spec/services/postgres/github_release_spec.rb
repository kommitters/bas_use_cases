# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'securerandom'

require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_release'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubRelease do
  include TestDBHelpers

  # Use an in-memory SQLite database for testing
  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }

  before(:each) do
    db.drop_table?(:github_releases)

    create_github_releases_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new github_release and returns its ID' do
      params = {
        external_github_release_id: 1, # Changed from string to integer
        repository_id: 12_345,
        tag_name: 'v1.0.0',
        creation_timestamp: Time.now,
        name: 'First Release'
      }
      id = service.insert(params)
      release = service.find(id)

      expect(release).not_to be_nil
      expect(release[:external_github_release_id]).to eq(1) # Expect an integer
      expect(release[:repository_id]).to eq(12_345)
      expect(release[:tag_name]).to eq('v1.0.0')
      expect(release[:name]).to eq('First Release')
    end

    it 'creates a new historical record when inserting a release with the same external_id' do
      params1 = {
        external_github_release_id: 10,
        repository_id: 1000,
        tag_name: 'v1.0-hist',
        name: 'Historical Release v1',
        is_prerelease: true,
        creation_timestamp: Time.now
      }
      service.insert(params1)

      expect(service.query(external_github_release_id: 10).size).to eq(1)

      params2 = {
        external_github_release_id: 10,
        repository_id: 1000,
        tag_name: 'v1.0-hist',
        name: 'Historical Release v2 - Final',
        is_prerelease: false,
        creation_timestamp: Time.now
      }
      service.insert(params2)

      releases = service.query(external_github_release_id: 10)
      expect(releases.size).to eq(2)

      names = releases.map { |r| r[:name] }.sort
      prerelease_statuses = releases.map { |r| r[:is_prerelease] }

      expect(names).to eq(['Historical Release v1', 'Historical Release v2 - Final'])
      expect(prerelease_statuses).to contain_exactly(true, false)
    end
  end

  describe '#update' do
    let!(:release_id) do
      service.insert(
        external_github_release_id: 2, # Changed from string to integer
        repository_id: 54_321,
        tag_name: 'v1.1.0',
        name: 'Initial Release',
        creation_timestamp: Time.now
      )
    end

    it 'updates a github_release by its ID' do
      service.update(release_id, { name: 'Updated Release Name', is_prerelease: true })
      updated_release = service.find(release_id)

      expect(updated_release[:name]).to eq('Updated Release Name')
      expect(updated_release[:is_prerelease]).to be true
      expect(updated_release[:repository_id]).to eq(54_321)
    end

    it 'can update the repository_id' do
      service.update(release_id, { repository_id: 99_999 })
      updated_release = service.find(release_id)

      expect(updated_release[:repository_id]).to eq(99_999)
    end

    it 'raises an ArgumentError if no ID is provided' do
      # Suppress console output from the `handle_error` method for this specific test.
      allow($stdout).to receive(:write)

      expect do
        service.update(nil, { name: 'No ID' })
      end.to raise_error(ArgumentError, 'GithubRelease id is required to update')
    end
  end

  describe '#delete' do
    it 'deletes a github_release by ID' do
      id_to_delete = service.insert(
        external_github_release_id: 3, # Changed from string to integer
        repository_id: 67_890,
        tag_name: 'v2.0.0-beta',
        creation_timestamp: Time.now
      )

      expect { service.delete(id_to_delete) }.to change { service.query.size }.by(-1)
      expect(service.find(id_to_delete)).to be_nil
    end
  end

  describe '#query' do
    before do
      service.insert(
        external_github_release_id: 4, # Changed from string to integer
        repository_id: 111,
        tag_name: 'v3.0.0',
        name: 'Find Me',
        creation_timestamp: Time.now
      )
      service.insert(
        external_github_release_id: 5, # Changed from string to integer
        repository_id: 222,
        tag_name: 'v3.0.1',
        name: 'Another One',
        creation_timestamp: Time.now
      )
    end

    it 'queries github_releases by a specific condition' do
      results = service.query(repository_id: 111)
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('Find Me')
    end

    it 'returns all releases with empty conditions' do
      expect(service.query.size).to eq(2)
    end
  end
end
