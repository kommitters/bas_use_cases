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
          database: config[:database],
          user: config[:user],
          password: config[:password],
          port: config[:port]
        )
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
        if timestamp?(table_name)
          now = Time.now
          params[:created_at] ||= now
          params[:updated_at] ||= now
        end

        db[table_name].insert(params)
      end

      def update_item(table_name, id, params)
        params[:updated_at] = Time.now if timestamp?(table_name)

        db[table_name].where(id: id).update(params)
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
        return unless self.class.const_defined?(:RELATIONS)

        relations = self.class.const_get(:RELATIONS)
        relations.each do |relation|
          next unless params.key?(relation[:external])

          params[relation[:internal]] = fetch_foreign_id(params[relation[:external]], relation)
          params.delete(relation[:external])
        end
      end

      #  Fetches the foreign ID based on the external ID and relation definition.
      def fetch_foreign_id(external_id, relation)
        return nil unless external_id

        record = relation[:service].new(db).query(relation[:external] => external_id).first
        record ? record[:id] : nil
      end
    end
  end
end
