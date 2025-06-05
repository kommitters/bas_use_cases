# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:project) do
      primary_key :id, size: 255
      String :external_project_id, size: 255, null: false
      String :name, null: false
      String :type, size: 100, null: false
      String :weekly_scope_id, size: 255, null: true
      String :domain_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:project)
  end
end
