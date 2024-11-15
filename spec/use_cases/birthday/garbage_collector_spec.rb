# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/garbage_collector'
require 'bas/shared_storage/postgres'

ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'
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

RSpec.describe Bot::GarbageCollector do
  before do
    write_options =
      {
        connection: CONNECTION,
        db_table: 'birthday'
      }

    options =
      {
        connection: CONNECTION,
        db_table: 'birthday'
      }

    shared_storage = SharedStorage::Postgres.new({ write_options: })

    @bot = Bot::GarbageCollector.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::GarbageCollector)

      allow(Bot::GarbageCollector).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
