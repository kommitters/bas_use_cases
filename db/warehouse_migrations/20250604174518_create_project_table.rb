# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:projects) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_project_id, size: 255, null: false
      String :name, size: 255, null: false
      String :type, size: 100, null: false
      String :external_weekly_scope_id, size: 255, null: true
      String :external_domain_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:projects)
  end
end
