module Services
  module Postgres
    module Audit
      def save_history(table_name, id)
        return unless history_enabled?
        current_record = find_item(table_name, id)
        return unless current_record
        history_params = prepare_history_params(id, current_record)
        insert_history_record(history_params)
      end

      def history_enabled?
        self.class.const_defined?(:HISTORY_TABLE) && self.class.const_defined?(:HISTORY_FOREIGN_KEY)
      end

      def prepare_history_params(parent_id, record_data)
        foreign_key = self.class::HISTORY_FOREIGN_KEY
        record_data.dup.tap do |params|
          params.delete(:id)
          params[foreign_key] = parent_id
        end
      end

      def insert_history_record(params)
        history_table = self.class::HISTORY_TABLE
        transaction { db[history_table].insert(params) }
      end
    end
  end
end