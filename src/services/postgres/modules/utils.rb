module Services
  module Postgres
    module Utils
      def symbolize_keys(hash)
        hash.transform_keys { |k| k.to_sym rescue k }
      end

      def entity_attributes(params)
        params.select { |key, _| attributes.include?(key) }
      end

      def attributes
        %i[id created_at updated_at] + self.class.const_get(:ATTRIBUTES)
      end
    end
  end
end