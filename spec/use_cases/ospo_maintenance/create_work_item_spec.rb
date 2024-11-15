# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/create_work_item'
require 'bas/shared_storage/postgres'

ENV['OSPO_MAINTENANCE_NOTION_DATABASE_ID'] = 'OSPO_MAINTENANCE_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'
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
}.freeze

RSpec.describe Bot::CreateWorkItem do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'github_issues',
      tag: 'CreateWorkItemRequest'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'github_issues',
      tag: 'CreateWorkItem'
    }

    options = {
      database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::CreateWorkItem.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::CreateWorkItem)

      allow(Bot::CreateWorkItem).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
