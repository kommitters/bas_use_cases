# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:activity) do
      primary_key :id, size: 255
      String :external_activity_id, size: 255, null: false
      String :name, null: false
      String :domain_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:activity)
  end
end
