# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_emails_from_imap'
require_relative 'config'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

# Configuration

write_options = {
  connection: Config::CONNECTION,
  db_table: 'support_emails',
  tag: 'FetchEmailsFromImap'
}

params = {
  refresh_token: Config::REFRESH_TOKEN,
  client_id: Config::CLIENT_ID,
  client_secret: Config::CLIENT_SECRET,
  token_uri: Config::TOKEN_URI,
  email_domain: 'imap.gmail.com',
  email_port: 993,
  user_email: ENV.fetch('SUPPORT_EMAIL_ACCOUNT'),
  search_email: ENV.fetch('SUPPORT_EMAIL_RECEPTOR'),
  inbox: 'INBOX'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Bot::FetchEmailsFromImap.new(params, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
