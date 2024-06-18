# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/support_email/fetch_emails_from_imap'

ENV['SUPPORT_EMAIL_TABLE'] = 'SUPPORT_EMAIL_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['DB_NAME'] = 'DB_NAME'
ENV['DB_USER'] = 'DB_USER'
ENV['DB_PASSWORD'] = 'DB_PASSWORD'
ENV['SUPPORT_EMAIL_ACCOUNT'] = 'SUPPORT_EMAIL_ACCOUNT'
ENV['SUPPORT_EMAIL_REFRESH_TOKEN'] = 'SUPPORT_EMAIL_REFRESH_TOKEN'
ENV['SUPPORT_EMAIL_CLIENT_ID'] = 'SUPPORT_EMAIL_CLIENT_ID'
ENV['SUPPORT_EMAIL_CLIENT_SECRET'] = 'SUPPORT_EMAIL_CLIENT_SECRET'
ENV['SUPPORT_EMAIL_INBOX'] = 'SUPPORT_EMAIL_INBOX'
ENV['SUPPORT_EMAIL_RECEPTOR'] = 'SUPPORT_EMAIL_RECEPTOR'

RSpec.describe Fetch::EmailsFromImap do
  before do
    params = {
      table_name: ENV.fetch('SUPPORT_EMAIL_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('DB_NAME'),
      db_user: ENV.fetch('DB_USER'),
      db_password: ENV.fetch('DB_PASSWORD'),
      email_account: ENV.fetch('SUPPORT_EMAIL_ACCOUNT'),
      email_refresh_token: ENV.fetch('SUPPORT_EMAIL_REFRESH_TOKEN'),
      email_client_id: ENV.fetch('SUPPORT_EMAIL_CLIENT_ID'),
      email_client_secret: ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET'),
      email_inbox: ENV.fetch('SUPPORT_EMAIL_INBOX'),
      email_receptor: ENV.fetch('SUPPORT_EMAIL_RECEPTOR'),
      email_token_uri: 'https://oauth2.googleapis.com/token',
      email_port: 993,
      email_domain: 'imap.gmail.com'
    }

    @bot = Fetch::EmailsFromImap.new(params)
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
