# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:persons) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_person_id, size: 255, null: false
      String :full_name, size: 255, null: false
      String :email_address, size: 255, null: false
      String :role, size: 100, null: true
      Boolean :is_active, default: false, null: true
      DateTime :hire_date, null: true
      DateTime :exit_date, null: true
      String :github_username, size: 255, null: true
      String :notion_user_id, size: 255, null: true
      String :worklogs_user_id, size: 255, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:persons)
  end
end
