# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:weekly_scope_tasks) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_weekly_scope_task_id, size: 255, null: false
      foreign_key :task_id, :tasks, null: false, on_delete: :cascade, type: :uuid
      foreign_key :weekly_scope_id, :weekly_scopes, null: false, on_delete: :cascade, type: :uuid
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:weekly_scope_tasks)
  end
end
