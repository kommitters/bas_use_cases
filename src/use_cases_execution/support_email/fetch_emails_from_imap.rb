# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_emails_from_imap'
require_relative 'config'

# Configuration

write_options = {
  connection: SupportEmailConfig::CONNECTION,
  db_table: 'support_emails',
  tag: 'FetchEmailsFromImap'
}

params = {
  refresh_token: SupportEmailConfig::REFRESH_TOKEN,
  client_id: SupportEmailConfig::CLIENT_ID,
  client_secret: SupportEmailConfig::CLIENT_SECRET,
  token_uri: SupportEmailConfig::TOKEN_URI,
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

  Implementation::FetchEmailsFromImap.new(params, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
