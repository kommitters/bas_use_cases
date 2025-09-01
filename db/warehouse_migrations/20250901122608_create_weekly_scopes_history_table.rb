# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:weekly_scopes_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_weekly_scope_id, size: 255, null: true
      foreign_key :weekly_scope_id, :weekly_scopes, null: false, on_delete: :cascade, type: :uuid
      foreign_key :domain_id, :domains, null: true, on_delete: :cascade, type: :uuid
      foreign_key :person_id, :persons, null: true, on_delete: :cascade, type: :uuid
      String :description, size: 255, null: false
      DateTime :start_week_date, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :end_week_date, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:weekly_scopes_history)
  end
end
