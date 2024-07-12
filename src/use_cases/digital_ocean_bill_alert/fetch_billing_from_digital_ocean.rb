# frozen_string_literal: true

require 'bas/bot/fetch_billing_from_digital_ocean'
require 'json'

module Fetch
  # Service to fetch Digital Ocean current balance
  class BillingFromDigitalOcean
    def initialize(params)
      @digital_ocean_secret = params[:digital_ocean_secret]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { process_options:, write_options: }

      bot = Bot::FetchBillingFromDigitalOcean.new(options)

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

    def process_options
      { secret: @digital_ocean_secret }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FetchBillingFromDigitalOcean'
      }
    end
  end
end
