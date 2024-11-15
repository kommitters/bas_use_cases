# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/implementations/fetch_domain_services_from_notion'

ENV['WEBSITES_AVAILABILITY_NOTION_DATABASE_ID'] = 'WEBSITES_AVAILABILITY_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['WEBSITES_AVAILABILITY_TABLE'] = 'WEBSITES_AVAILABILITY_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}.freeze

RSpec.describe Bot::FetchDomainServicesFromNotion do
  before do
    write_options = {
      connection: CONNECTION,
      db_table: 'web_availability',
      tag: 'FetchDomainServicesFromNotion'
    }

    options = {
      database_id: ENV.fetch('WEBSITES_AVAILABILITY_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    shared_storage_reader = Bas::SharedStorage::Default.new
    shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

    @bot = Bot::FetchDomainServicesFromNotion.new(options, shared_storage_reader, shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchDomainServicesFromNotion)

      allow(Bot::FetchDomainServicesFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
