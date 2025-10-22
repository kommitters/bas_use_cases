# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:tasks) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_task_id, size: 255, null: false
      foreign_key :process_id, :processes, null: true, on_delete: :cascade, type: :uuid
      foreign_key :milestone_id, :milestones, null: true, on_delete: :cascade, type: :uuid
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      String :assigned_to, size: 255, null: true
      String :status, size: 50, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:tasks)
  end
end
