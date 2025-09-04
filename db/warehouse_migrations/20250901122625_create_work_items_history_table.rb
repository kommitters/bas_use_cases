# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:work_items_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_work_item_id, size: 255, null: false
      foreign_key :work_item_id, :work_items, null: false, on_delete: :cascade, type: :uuid
      foreign_key :project_id, :projects, type: :uuid, null: true
      foreign_key :activity_id, :activities, type: :uuid, null: true
      foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: true
      foreign_key :person_id, :persons, type: :uuid, null: true
      foreign_key :github_issue_id, :github_issues, type: :uuid, null: true
      String :name, size: 100, null: true
      String :status, size: 50, null: false
      String :description, size: 255, null: false
      DateTime :completion_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:work_items_history)
  end
end
