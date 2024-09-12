# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/support_email/fetch_emails_from_imap'

# Configuration
params = {
  table_name: 'support_emails',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD'),
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

# Process bot
begin
  bot = Fetch::EmailsFromImap.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
