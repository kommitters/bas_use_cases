# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/fetch_billing_from_digital_ocean'

ENV['DIGITAL_OCEAN_SECRET'] = 'DIGITAL_OCEAN_SECRET'
ENV['DO_TABLE'] = 'DO_TABLE'
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

RSpec.describe Bot::FetchBillingFromDigitalOcean do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'do_billing',
      tag: 'FetchBillingFromDigitalOcean',
      avoid_process: true,
      where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
      params: [false, 'FetchBillingFromDigitalOcean']
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'do_billing',
      tag: 'FetchBillingFromDigitalOcean'
    }

    options = {
      secret: ENV.fetch('DIGITAL_OCEAN_SECRET')
    }

    shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::FetchBillingFromDigitalOcean.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchBillingFromDigitalOcean)

      allow(Bot::FetchBillingFromDigitalOcean).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
