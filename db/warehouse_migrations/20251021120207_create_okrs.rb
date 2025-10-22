# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:okrs) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_okr_id, size: 255, null: false
      String :code, size: 20, null: true
      String :status, size: 50, null: true
      String :objective, size: 2000, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:okrs)
  end
end
