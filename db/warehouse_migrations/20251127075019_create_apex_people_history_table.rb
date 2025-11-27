# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:apex_people_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_person_id, size: 255, null: false
      foreign_key :person_id, :apex_people, type: :uuid, null: false
      foreign_key :org_unit_id, :organizational_units, type: :uuid, null: true
      String :full_name, size: 255, null: false
      String :email_address, size: 255, null: false
      String :role, size: 100, null: true
      String :job_title, size: 255, null: true
      Boolean :is_active, default: false, null: true
      DateTime :hire_date, null: true
      DateTime :exit_date, null: true
      String :github_username, size: 255, null: true
      String :worklogs_user_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:apex_people_history)
  end
end
