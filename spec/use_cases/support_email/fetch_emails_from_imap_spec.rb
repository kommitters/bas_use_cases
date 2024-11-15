# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/implementations/fetch_emails_from_imap'

ENV['SUPPORT_EMAIL_TABLE'] = 'SUPPORT_EMAIL_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'
ENV['SUPPORT_EMAIL_ACCOUNT'] = 'SUPPORT_EMAIL_ACCOUNT'
ENV['SUPPORT_EMAIL_REFRESH_TOKEN'] = 'SUPPORT_EMAIL_REFRESH_TOKEN'
ENV['SUPPORT_EMAIL_CLIENT_ID'] = 'SUPPORT_EMAIL_CLIENT_ID'
ENV['SUPPORT_EMAIL_CLIENT_SECRET'] = 'SUPPORT_EMAIL_CLIENT_SECRET'
ENV['SUPPORT_EMAIL_INBOX'] = 'SUPPORT_EMAIL_INBOX'
ENV['SUPPORT_EMAIL_RECEPTOR'] = 'SUPPORT_EMAIL_RECEPTOR'

CONNECTION = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD'),
}

RSpec.describe Bot::FetchEmailsFromImap do
  before do
    write_options = {
      connection: CONNECTION,
      db_table: 'support_emails',
      tag: 'FetchEmailsFromImap'
    }
    
    params = {
      refresh_token: ENV.fetch('REFRESH_TOKEN'),
      client_id: ENV.fetch('CLIENT_ID'),
      client_secret: ENV.fetch('CLIENT_SECRET'),
      token_uri: ENV.fetch('TOKEN_URI'),
      email_domain: 'imap.gmail.com',
      email_port: 993,
      user_email: ENV.fetch('SUPPORT_EMAIL_ACCOUNT'),
      search_email: ENV.fetch('SUPPORT_EMAIL_RECEPTOR'),
      inbox: 'INBOX'
    }

    shared_storage_reader = SharedStorage::Default.new
  shared_storage_writer = SharedStorage::Postgres.new({ write_options: })

  @bot = Bot::FetchEmailsFromImap.new(params, shared_storage_reader, shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchEmailsFromImap)

      allow(Bot::FetchEmailsFromImap).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
