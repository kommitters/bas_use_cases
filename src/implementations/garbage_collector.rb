# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/postgres/request'

module Implementation
  ##
  # The Implementation::GarbageCollector class serves as a bot implementation to archive bot records from a
  # PostgresDB database table and write a response on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "review_images"
  #   }
  #
  #   options = {
  #     connection:,
  #     db_table: "review_images"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::GarbageCollector.new(options, shared_storage).execute
  #
  class GarbageCollector < Bas::Bot::Base
    SUCCESS_STATUS = 'PGRES_COMMAND_OK'

    # Process function to update records in a PostgresDB database table
    #
    def process
      Utils::Postgres::Request.execute(params)
      { success: { archived: true } }
    end

    private

    def params
      {
        connection: process_options[:connection],
        query:
      }
    end

    def query
      "UPDATE #{process_options[:db_table]} SET archived=true WHERE archived=false"
    end
  end
end
