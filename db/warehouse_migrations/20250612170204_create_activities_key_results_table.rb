# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:activities_key_results) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      foreign_key :activity_id, :activities, null: false, on_delete: :cascade, type: :uuid
      foreign_key :key_result_id, :key_results, null: false, on_delete: :cascade, type: :uuid
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')

      index %i[activity_id key_result_id], unique: true
    end
  end

  down do
    drop_table(:activities_key_results)
  end
end
