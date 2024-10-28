# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/ospo_maintenance/fetch_github_issues'

ENV['OSPO_MAINTENANCE_SECRET'] = 'OSPO_MAINTENANCE_SECRET'
ENV['OSPO_MAINTENANCE_APP_ID'] = 'OSPO_MAINTENANCE_APP_ID'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Fetch::GithubIssues do
  before do
    params = {
      tag: 'GithubIssues',
      repo: 'org/repo',
      organization: 'org',
      domain: 'domain',
      work_item_type: 'activity',
      type_id: '123456789',
      private_pem: 'OSPO_MAINTENANCE_SECRET',
      app_id: ENV.fetch('OSPO_MAINTENANCE_APP_ID'),
      table_name: ENV.fetch('OSPO_MAINTENANCE_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Fetch::GithubIssues.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchGithubIssues)

      allow(Bot::FetchGithubIssues).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
