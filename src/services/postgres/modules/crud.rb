module Services
  module Postgres
    module CRUD
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
        db[table_name].insert(entity_attributes(params))
      end

      def update_item(table_name, id, params)
        save_history(table_name, id) if respond_to?(:save_history)
        params = symbolize_keys(params)
        db[table_name].where(id: id).update(entity_attributes(params))
      end

      def delete_item(table_name, id)
        db[table_name].where(id: id).delete
      end

      def transaction(&block)
        db.transaction(&block)
      end
    end
  end
end