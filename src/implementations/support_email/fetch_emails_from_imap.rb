# frozen_string_literal: true

require 'bas/bot/fetch_emails_from_imap'
require 'json'

module Fetch
  # Service to fetch emails from an imap server
  class EmailsFromImap
    def initialize(params)
      @params = params
    end

    def execute
      options = { process_options:, write_options: }

      bot = Bot::FetchEmailsFromImap.new(options)

      bot.execute
    end

    private

    def connection
      {
        host: @params[:db_host],
        port: @params[:db_port],
        dbname: @params[:db_name],
        user: @params[:db_user],
        password: @params[:db_password]
      }
    end

    def process_options
      {
        refresh_token: @params[:email_refresh_token], client_id: @params[:email_client_id],
        client_secret: @params[:email_client_secret], token_uri: @params[:email_token_uri],
        email_domain: @params[:email_domain], email_port: @params[:email_port],
        user_email: @params[:email_account], search_email: @params[:email_receptor],
        inbox: @params[:email_inbox]
      }
    end

    def write_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: 'FetchEmailsFromImap'
      }
    end
  end
end
