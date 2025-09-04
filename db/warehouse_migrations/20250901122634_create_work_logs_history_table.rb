# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:work_logs_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_work_log_id, size: 255, null: false
      foreign_key :work_log_id, :work_logs, null: false, on_delete: :cascade, type: :uuid
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      foreign_key :activity_id, :activities, type: :uuid, null: true, on_delete: :cascade
      foreign_key :work_item_id, :work_items, type: :uuid, null: true, on_delete: :cascade
      Integer :duration_minutes, null: false
      column :tags, 'text[]', null: true
      DateTime :creation_date, null: false
      DateTime :modification_date, null: true
      Boolean :external, null: true
      Boolean :deleted, null: true
      DateTime :started_at, null: false
      String :description, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:work_logs_history)
  end
end
