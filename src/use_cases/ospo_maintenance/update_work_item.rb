# frozen_string_literal: true

require 'bas/bot/update_work_item'
require 'json'

module Update
  # Service to fetch ptos from a notion database
  class WorkItem
    def initialize(params)
      @params = params
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::UpdateWorkItem.new(options)

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
        db_table: @params[:table_name],
        tag: 'UpdateWorkItemRequest'
      }
    end

    def process_options
      {
        users_database_id: @params[:users_database_id],
        secret: @params[:secret]
      }
    end

    def write_options
      {
        connection:,
        db_table: @params[:table_name],
        tag: 'UpdateWorkItem'
      }
    end
  end
end
