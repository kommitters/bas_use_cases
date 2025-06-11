# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:activities) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_activity_id, size: 255, null: false
      String :name, null: false
      String :external_domain_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:activities)
  end
end
