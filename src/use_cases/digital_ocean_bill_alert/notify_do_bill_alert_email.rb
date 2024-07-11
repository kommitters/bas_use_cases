# frozen_string_literal: true

require 'bas/bot/notify_do_bill_alert_email'
require 'json'

module Notify
  # Service to format digital ocean billing alerts
  class DoBillAlertEmail
    def initialize(params)
      @refresh_token = params[:refresh_token]
      @client_id = params[:client_id]
      @client_secret = params[:client_secret]
      @user_email = params[:user_email]
      @recipient_email = params[:recipient_email]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::NotifyDoBillAlertEmail.new(options)

      bot.execute
    end

    private

    def connection
      {
        host: @db_host,
        port: @db_port,
        dbname: @db_name,
        user: @db_user,
        password: @db_password
      }
    end

    def read_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FormatDoBillAlert',
        avoid_process: true
      }
    end

    def process_options
      {
        refresh_token: @refresh_token,
        client_id: @client_id,
        client_secret: @client_secret,
        user_email: @user_email,
        recipient_email: @recipient_email
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'NotifyDoBillAlertEmail'
      }
    end
  end
end
