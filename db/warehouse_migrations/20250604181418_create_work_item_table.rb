# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:work_items) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_work_item_id, size: 255, null: false
      foreign_key :project_id, :projects, type: :uuid, null: true
      foreign_key :activity_id, :activities, type: :uuid, null: true
      String :external_domain_id, size: 255, null: true
      String :external_weekly_scope_id, size: 255, null: true
      String :work_item_status, size: 50, null: false
      DateTime :work_item_completion_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:work_items)
  end
end
