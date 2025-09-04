# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:projects_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_project_id, size: 255, null: false
      foreign_key :project_id, :projects, null: false, on_delete: :cascade, type: :uuid
      foreign_key :domain_id, :domains, null: false, on_delete: :cascade, type: :uuid
      String :name, size: 255, null: false
      String :status, size: 100, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:projects_history)
  end
end
