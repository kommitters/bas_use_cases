# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/fetch_domains_wip_limit'

ENV['WIP_LIMIT_NOTION_DATABASE_ID'] = 'WIP_LIMIT_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['WIP_TABLE'] = 'WIP_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

RSpec.describe Bot::FetchDomainsWipLimitFromNotion do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'wip_limits',
      tag: 'FetchDomainsWipCountsFromNotion'
    }
    
    write_options = {
      connection: CONNECTION,
      db_table: 'wip_limits',
      tag: 'FetchDomainsWipLimitFromNotion'
    }
    
    options = {
      database_id: ENV.fetch('WIP_COUNT_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::FetchDomainsWipLimitFromNotion.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchDomainsWipLimitFromNotion)

      allow(Bot::FetchDomainsWipLimitFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
