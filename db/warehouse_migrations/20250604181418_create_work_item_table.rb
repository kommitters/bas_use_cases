# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:work_item) do
      primary_key :id, size: 255
      String :external_work_item_id, size: 255, null: false
      foreign_key :project_id, :project, size: 255, null: true
      foreign_key :activity_id, :activity, size: 255, null: true
      String :assignee_person_id, size: 255, null: true
      String :external_domain_id, size: 255, null: true
      String :external_weekly_scope_id, size: 255, null: true
      String :work_item_status, size: 50, null: false
      DateTime :work_item_completetion_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:work_item)
  end
end
