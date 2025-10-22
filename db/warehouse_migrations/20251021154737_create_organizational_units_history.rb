# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:organizational_units_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_org_unit_id, size: 255, null: false
      foreign_key :organizational_unit_id, :organizational_units, type: :uuid
      foreign_key :parent_org_id, :organizational_units, type: :uuid, on_delete: :cascade, null: true
      String :name, size: 255, null: false
      String :status, size: 50, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:organizational_units_history)
  end
end
