# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module SupportEmailConfig
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
    { path: '/support_email/fetch_emails_from_imap.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'] },
    { path: '/support_email/format_emails.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'] },
    { path: '/support_email/garbage_collector.rb', time: ['21:10:00'] },
    { path: '/support_email/notify_support_emails.rb', time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'] }
  ].freeze
end
