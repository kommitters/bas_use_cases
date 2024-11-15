# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/implementations/fetch_next_week_pto_from_notion'

ENV['PTO_NOTION_DATABASE_ID'] = 'PTO_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['PTO_TABLE'] = 'PTO_TABLE'
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

RSpec.describe Bot::FetchNextWeekPtosFromNotion do
  before do
    options = {
      database_id: ENV.fetch('PTO_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'pto',
      tag: 'FetchNextWeekPtosFromNotion'
    }

    shared_storage_reader = Bas::SharedStorage::Default.new
    shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

    @bot = Bot::FetchNextWeekPtosFromNotion.new(options, shared_storage_reader, shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchNextWeekPtosFromNotion)

      allow(Bot::FetchNextWeekPtosFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
