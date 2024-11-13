# frozen_string_literal: true

require 'bas/bot/humanize_pto'
require 'json'

module Humanize
  # Service to humanize ptos messages
  class Pto
    def initialize(params)
      @openai_secret = params[:openai_secret]
      @openai_assistant = params[:openai_assistant]
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::HumanizePto.new(options)

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
        tag: 'FetchPtosFromNotion'
      }
    end

    def process_options
      utc_today = Time.now.utc
      today = Time.at(utc_today, in: '-05:00').strftime('%F').to_s

      {
        secret: @openai_secret,
        assistant_id: @openai_assistant,
        prompt: "Today is #{today} and the PTO's are: {data}. Notify only todays information"
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'HumanizePto'
      }
    end
  end
end
