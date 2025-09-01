# frozen_string_literal: true

require 'sequel'

module Services
  module Postgres
    ##
    # Base Database Service Class
    #
    # A foundational service class that provides common database operations
    # using Sequel ORM. This class serves as a base for other service classes
    # that need to interact with PostgreSQL databases.
    class Base
      attr_reader :config, :db

      def initialize(config_or_db)
        Sequel.extension :pg_json

        if config_or_db.is_a?(Sequel::Database)
          @db = config_or_db
          @config = nil
        else
          @config = config_or_db
          @db = establish_connection
        end
      end

      private

      def establish_connection
        Sequel.connect(
          adapter: 'postgres',
          host: config[:host],
          database: config[:dbname],
          user: config[:user],
          password: config[:password],
          port: config[:port]
        )
      end

      def entity_attributes(params)
        params.select { |key, _| attributes.include?(key) }
      end

      def attributes
        %i[id created_at updated_at] + self.class.const_get(:ATTRIBUTES)
      end

      protected

      def query_item(table_name, conditions = {})
        dataset = db[table_name]
        dataset = dataset.where(conditions) unless conditions.empty?
        dataset.all
      end

      def find_item(table_name, id)
        db[table_name].where(id: id).first
      end

      def insert_item(table_name, params)
        params = symbolize_keys(params)
        if timestamp?(table_name)
          now = Time.now
          params[:created_at] ||= now
          params[:updated_at] ||= now
        end

        attr = entity_attributes(params)
        db[table_name].insert(attr)
      end

      def update_item(table_name, id, params)
        # Automatically saves the current state to the history table before updating.
        save_history(id)

        params = symbolize_keys(params)
        params[:updated_at] = Time.now if timestamp?(table_name)

        attr = entity_attributes(params)
        db[table_name].where(id: id).update(attr)
      end

      def delete_item(table_name, id)
        db[table_name].where(id: id).delete
      end

      def transaction(&block)
        db.transaction(&block)
      end

      def timestamp?(table_name)
        schema = db.schema(table_name)
        column_names = schema.map(&:first)
        column_names.include?(:created_at) && column_names.include?(:updated_at)
      end

      # Assigns foreign relations based on the defined RELATIONS constant.
      def assign_relations(params)
        params.replace(symbolize_keys(params))

        self.class.const_get(:RELATIONS).each do |relation|
          external_key = relation[:external]
          internal_key = relation[:internal]
          next unless params.key?(external_key)

          params[internal_key] = fetch_foreign_id(params[external_key], relation)
        end
      end

      #  Fetches the foreign ID based on the external ID and relation definition.
      def fetch_foreign_id(external_id, relation)
        record = relation[:service].new(db).query(relation[:external] => external_id).first
        record ? record[:id] : nil
      end

      def symbolize_keys(hash)
        hash.transform_keys do |k|
          k.to_sym
        rescue StandardError
          k
        end
      end

      ##
      # Saves the current state of a record to its corresponding history table.
      # This method is called automatically from `update_item`.
      #
      # It only runs if the calling service class defines the constants:
      # - HISTORY_TABLE: The name of the history table (e.g., :activities_history).
      # - HISTORY_FOREIGN_KEY: The name of the foreign key column (e.g., :activity_id).
      #
      def save_history(id)
        return unless self.class.const_defined?(:HISTORY_TABLE) && self.class.const_defined?(:HISTORY_FOREIGN_KEY)

        require_relative 'history_service'

        table_name = self.class::TABLE
        history_table = self.class::HISTORY_TABLE
        foreign_key = self.class::HISTORY_FOREIGN_KEY

        current_record = find_item(table_name, id)
        return unless current_record

        history_service = HistoryService.new(db, history_table, foreign_key)
        history_service.save(id, current_record)
      end
    end
  end
end
