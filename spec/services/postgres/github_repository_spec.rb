# frozen_string_literal: true

require 'sequel'
require 'rspec'
require 'json'

require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/github_repository'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::GithubRepository do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }

  before(:each) do
    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)

    db.drop_table?(:github_repositories)
    create_github_repositories_table(db)
  end

  describe '#insert' do
    it 'creates a new github_repository and returns its ID' do
      params = {
        external_github_repository_id: 123_456,
        name: 'awesome-repo',
        language: 'Ruby',
        description: 'An awesome repository',
        html_url: 'https://github.com/org/awesome-repo',
        is_private: false,
        is_fork: false,
        is_archived: false,
        is_disabled: false,
        watchers_count: 10,
        stargazers_count: 20,
        forks_count: 5,
        owner: JSON.generate({ login: 'org', id: 1 }),
        creation_timestamp: Time.now
      }

      id = service.insert(params)
      record = service.find(id)

      expect(record).not_to be_nil
      expect(record[:external_github_repository_id]).to eq(123_456)
      expect(record[:name]).to eq('awesome-repo')
      expect(record[:language]).to eq('Ruby')
      expect(record[:description]).to eq('An awesome repository')
      expect(record[:html_url]).to eq('https://github.com/org/awesome-repo')
      expect(record[:is_private]).to be(false)
      expect(record[:is_fork]).to be(false)
      expect(record[:is_archived]).to be(false)
      expect(record[:is_disabled]).to be(false)
      expect(record[:watchers_count]).to eq(10)
      expect(record[:stargazers_count]).to eq(20)
      expect(record[:forks_count]).to eq(5)
      expect(record[:owner]).to eq('{"login":"org","id":1}')
    end
  end

  describe '#update' do
    let!(:repo_id) do
      service.insert(
        external_github_repository_id: 999,
        name: 'start-repo',
        creation_timestamp: Time.now
      )
    end

    it 'updates a github_repository by its ID' do
      service.update(repo_id, { name: 'renamed-repo', stargazers_count: 42 })
      updated = service.find(repo_id)

      expect(updated[:name]).to eq('renamed-repo')
      expect(updated[:stargazers_count]).to eq(42)
    end

    it 'raises an ArgumentError if no ID is provided' do
      allow($stdout).to receive(:write)
      expect { service.update(nil, { name: 'nope' }) }
        .to raise_error(ArgumentError, 'GithubRepository id is required to update')
    end
  end

  describe '#delete' do
    it 'deletes a github_repository by ID' do
      id = service.insert(
        external_github_repository_id: 111,
        name: 'temp',
        creation_timestamp: Time.now
      )

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#query' do
    before do
      service.insert(external_github_repository_id: 1, name: 'a', language: 'Ruby', creation_timestamp: Time.now)
      service.insert(external_github_repository_id: 2, name: 'b', language: 'Go', creation_timestamp: Time.now)
    end

    it 'queries repositories by a specific condition' do
      results = service.query(language: 'Ruby')
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('a')
    end

    it 'returns all repositories with empty conditions' do
      expect(service.query.size).to eq(2)
    end
  end
end
