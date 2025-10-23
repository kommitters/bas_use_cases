# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:processes) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_process_id, size: 255, null: false
      foreign_key :org_unit_id, :organizational_units, type: :uuid, on_delete: :cascade
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      String :status, size: 50, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:processes)
  end
end
