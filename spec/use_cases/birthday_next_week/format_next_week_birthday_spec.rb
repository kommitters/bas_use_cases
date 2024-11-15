# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/format_birthday'
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

RSpec.describe Bot::FormatBirthdays do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'birthday',
      tag: 'FetchNextWeekBirthdaysFromNotion'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'birthday',
      tag: 'FormatNextWeekBirthdays'
    }

    options = {
      template: 'The Birthday of <name> is today! (<birthday_date>) :birthday: :gift:'
    }

    shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::FormatBirthdays.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FormatBirthdays)

      allow(Bot::FormatBirthdays).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
