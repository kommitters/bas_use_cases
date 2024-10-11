# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_emails_from_imap'

module UseCase
  # FetchEmailsFromImap
  #
  class FetchEmailsFromImap < UseCase::Base
    TABLE = 'support_emails'
    EMAIL_TOKEN_URI = 'https://oauth2.googleapis.com/token'
    EMAIL_DOMAIN = 'imap.gmail.com'
    EMAIL_PORT = 993

    def execute
      bot = Bot::FetchEmailsFromImap.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options:,
        write_options: { connection:, db_table: TABLE, tag: 'FetchEmailsFromImap' }
      }
    end

    def process_options # rubocop:disable Metrics/MethodLength
      {
        refresh_token: ENV.fetch('SUPPORT_EMAIL_REFRESH_TOKEN'),
        client_id: ENV.fetch('SUPPORT_EMAIL_CLIENT_ID'),
        client_secret: ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET'),
        token_uri: EMAIL_TOKEN_URI,
        email_domain: EMAIL_DOMAIN,
        email_port: EMAIL_PORT,
        user_email: ENV.fetch('SUPPORT_EMAIL_ACCOUNT'),
        search_email: ENV.fetch('SUPPORT_EMAIL_RECEPTOR'),
        inbox: ENV.fetch('SUPPORT_EMAIL_INBOX')
      }
    end
  end
end
