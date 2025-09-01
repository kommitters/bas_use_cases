# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:milestones_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_milestone_id, size: 255, null: false
      foreign_key :milestone_id, :milestones, null: false, on_delete: :cascade, type: :uuid
      foreign_key :project_id, :projects, type: :uuid, null: true
      String :name, size: 255, null: false
      String :status, size: 50, null: false
      DateTime :completion_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:milestones_history)
  end
end
