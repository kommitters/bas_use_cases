# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:krs_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_kr_id, size: 255, null: false
      foreign_key :kr_id, :krs, type: :uuid, null: false, on_delete: :cascade
      foreign_key :okr_id, :okrs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: true
      String :status, size: 50, null: true
      String :code, size: 20, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:krs_history)
  end
end
