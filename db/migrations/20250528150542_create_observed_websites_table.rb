# frozen_string_literal: true

Sequel.migration do
  up do
    create_table?(:observed_websites) do
      primary_key :id
      String :url, size: 255, null: false, unique: true
      DateTime :inserted_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table?(:observed_websites)
  end
end
