# frozen_string_literal: true

=begin
  INSTRUCTIONS:

  This file is used to store the configuration of the birthday use case.
  It contains the connection information to the database and the schedule of the bot.
  The schedule configuration has two fields: path and interval.
  The path is the path to the script that will be executed
  The interval is the time in milliseconds that the script will be executed
=end

require 'dotenv/load'

module Config
  REFRESH_TOKEN = ENV.fetch('SUPPORT_EMAIL_REFRESH_TOKEN')
  CLIENT_ID = ENV.fetch('SUPPORT_EMAIL_CLIENT_ID')
  CLIENT_SECRET = ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET')
  TOKEN_URI = 'https://oauth2.googleapis.com/token'

  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: "/fetch_emails_from_imap.rb", interval: 1000 },
    { path: "/format_emails.rb", interval: 1000},
    { path: "/garbage_collector.rb", interval: 1000},
    { path: "/notify_support_emails.rb", interval: 1000}
  ].freeze
end
