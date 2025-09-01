# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:activities_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_activity_id, size: 255, null: false
      foreign_key :activity_id, :activities, null: false, on_delete: :cascade, type: :uuid
      foreign_key :domain_id, :domains, null: false, on_delete: :cascade, type: :uuid
      String :name, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:activities_history)
  end
end
