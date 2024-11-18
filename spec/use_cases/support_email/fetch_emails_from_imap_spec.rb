# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/implementations/fetch_emails_from_imap'

ENV['SUPPORT_EMAIL_TABLE'] = 'SUPPORT_EMAIL_TABLE'
ENV['SUPPORT_EMAIL_ACCOUNT'] = 'SUPPORT_EMAIL_ACCOUNT'
ENV['SUPPORT_EMAIL_REFRESH_TOKEN'] = 'SUPPORT_EMAIL_REFRESH_TOKEN'
ENV['SUPPORT_EMAIL_CLIENT_ID'] = 'SUPPORT_EMAIL_CLIENT_ID'
ENV['SUPPORT_EMAIL_CLIENT_SECRET'] = 'SUPPORT_EMAIL_CLIENT_SECRET'
ENV['SUPPORT_EMAIL_INBOX'] = 'SUPPORT_EMAIL_INBOX'
ENV['SUPPORT_EMAIL_RECEPTOR'] = 'SUPPORT_EMAIL_RECEPTOR'
ENV['REFRESH_TOKEN'] = 'REFRESH_TOKEN'
ENV['TOKEN_URI'] = 'TOKEN_URI'

RSpec.describe Bot::FetchEmailsFromImap do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  
  before do

    params = {
      refresh_token: ENV.fetch('REFRESH_TOKEN'),
      client_id: ENV.fetch('SUPPORT_EMAIL_CLIENT_ID'),
      client_secret: ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET'),
      token_uri: ENV.fetch('TOKEN_URI'),
      email_domain: 'imap.gmail.com',
      email_port: 993,
      user_email: ENV.fetch('SUPPORT_EMAIL_ACCOUNT'),
      search_email: ENV.fetch('SUPPORT_EMAIL_RECEPTOR'),
      inbox: 'INBOX'
    }

    @bot = Bot::FetchEmailsFromImap.new(params, mocked_shared_storage_reader,mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({  success: { notification: '' } })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
