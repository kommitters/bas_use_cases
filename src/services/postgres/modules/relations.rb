module Services
  module Postgres
    module Relations
      def assign_relations(params)
        params.replace(symbolize_keys(params))
        self.class.const_get(:RELATIONS).each do |relation|
          external_key = relation[:external]
          internal_key = relation[:internal]
          next unless params.key?(external_key)
          params[internal_key] = fetch_foreign_id(params[external_key], relation)
        end
      end

      def fetch_foreign_id(external_id, relation)
        record = relation[:service].new(db).query(relation[:external] => external_id.to_s).first
        record ? record[:id] : nil
      end
    end
  end
end