# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_emails'

ENV['SUPPORT_EMAIL_TABLE'] = 'SUPPORT_EMAIL_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Bot::FormatEmails do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'support_emails',
      tag: 'FetchEmaisFromImap'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'support_emails',
      tag: 'FormatEmails'
    }

    options = {
      template: 'The <sender> has requested support the <date>',
      frequency: 5,
      timezone: '-05:00'
    }

    shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

    @bot = Bot::FormatEmails.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FormatEmails)

      allow(Bot::FormatEmails).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
