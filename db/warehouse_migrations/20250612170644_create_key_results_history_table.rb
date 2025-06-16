# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:key_results_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      foreign_key :key_result_id, :key_results, null: false, on_delete: :cascade, type: :uuid
      String :external_key_result_id, size: 255, null: true
      String :okr, size: 255, null: false
      String :key_result, size: 255, null: false
      Float :metric, null: false
      Float :current, null: false
      Float :progress, null: false
      String :period, size: 255, null: false
      String :objective, size: 255, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:key_results_history)
  end
end
