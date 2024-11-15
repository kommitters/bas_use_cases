# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/format_do_bill_alert'
require 'bas/shared_storage/postgres'

ENV['DIGITAL_OCEAN_THRESHOLD'] = 'DIGITAL_OCEAN_THRESHOLD'
ENV['DO_TABLE'] = 'DO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION = {
  host: ENV['DB_HOST'],
  port: ENV['DB_PORT'],
  db_name: ENV['POSTGRES_DB'],
  user: ENV['POSTGRES_USER'],
  password: ENV['POSTGRES_PASSWORD']
}.freeze

RSpec.describe Bot::FormatDoBillAlert do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'do_billing',
      tag: 'FetchBillingFromDigitalOcean'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'do_billing',
      tag: 'FormatDoBillAlert'
    }

    options = {
      threshold: ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
    }
    shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::FormatDoBillAlert.new(options, shared_storage).execute
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FormatDoBillAlert)

      allow(Bot::FormatDoBillAlert).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
