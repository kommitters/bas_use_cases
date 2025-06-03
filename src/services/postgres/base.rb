# frozen_string_literal: true

require 'sequel'

module Services
  ##
  # Base Database Service Class
  #
  # A foundational service class that provides common database operations
  # using Sequel ORM. This class serves as a base for other service classes
  # that need to interact with PostgreSQL databases.
  class Base
    attr_reader :config, :db

    def initialize(config)
      @config = config
      @db = establish_connection
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
  end
end
