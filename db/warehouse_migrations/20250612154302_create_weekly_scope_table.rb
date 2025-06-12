# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:weekly_scopes) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_weekly_scope_id, size: 255, null: true
      String :description, size: 255, null: false
      DateTime :start_week_date, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :end_week_date, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:weekly_scopes)
  end
end
