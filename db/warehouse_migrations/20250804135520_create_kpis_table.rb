# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:kpis) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_kpi_id, size: 255, null: true
      foreign_key :domain_id, :domains, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 255, null: true
      String :status, size: 255, null: true
      Float :current_value, null: true
      Float :percentage, null: true
      Float :target_value, null: true
      jsonb :stats, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:kpis)
  end
end
