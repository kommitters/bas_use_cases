# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Base Service for Operaton PostgreSQL tables
    #
    # Provides common CRUD operations for tables following a similar pattern.
    class OperatonBase < Services::Postgres::Base
      def insert(params)
        transaction { insert_item(self.class::TABLE, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def update(id, params)
        raise ArgumentError, "#{self.class.name.split('::').last} id is required to update" unless id

        transaction { update_item(self.class::TABLE, id, params) }
      rescue StandardError => e
        handle_error(e)
      end

      def delete(id)
        transaction { delete_item(self.class::TABLE, id) }
      rescue StandardError => e
        handle_error(e)
      end

      def find(id)
        find_item(self.class::TABLE, id)
      end

      def query(conditions = {})
        query_item(self.class::TABLE, conditions)
      rescue StandardError => e
        handle_error(e)
      end

      private

      def handle_error(error)
        puts "[#{self.class.name} ERROR] #{error.class}: #{error.message}"
        raise error
      end
    end
  end
end
