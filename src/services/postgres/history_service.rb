# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # HistoryService: A generic service for saving historical records.
    # It takes the history table name and the foreign key column as arguments.
    #
    class HistoryService < Services::Postgres::Base
      def initialize(db_connection, history_table, foreign_key_column)
        super(db_connection)
        @history_table = history_table
        @foreign_key_column = foreign_key_column
      end

      ##
      # Saves a historical record.
      def save(parent_id, record_data)
        history_params = record_data.dup
        history_params.delete(:id)
        history_params[@foreign_key_column] = parent_id

        transaction do
          db[@history_table].insert(history_params)
        end
      rescue StandardError => e
        puts "[HistoryService ERROR][#{@history_table}] #{e.class}: #{e.message}"
        raise e
      end

      ##
      # Queries the history table for records matching the conditions.
      def query(conditions = {})
        query_item(@history_table, conditions)
      end
    end
  end
end
