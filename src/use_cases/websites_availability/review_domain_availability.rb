# frozen_string_literal: true

require 'bas/bot/review_domain_availability'
require 'json'

module Review
  # Service to fetch images from a notion database
  class DomainAvailability
    def initialize(params)
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, write_options: }

      bot = Bot::ReviewDomainAvailability.new(options)

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
        tag: 'ReviewDomainRequest'
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'ReviewDomainAvailability'
      }
    end
  end
end
