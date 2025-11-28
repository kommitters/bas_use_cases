# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  up do
    alter_table(:github_issues) do
      add_column :status, String, size: 50, null: true
      add_column :title, String, size: 255, null: true
      add_column :number, Integer, null: true
      add_column :github_created_at, DateTime, null: true
      add_column :github_updated_at, DateTime, null: true

      set_column_allow_null :person_id, true

      drop_constraint :github_issues_person_id_fkey
      drop_column :person_id

      add_foreign_key :person_id, :apex_people, type: :uuid, null: true
    end

    alter_table(:github_issues_history) do
      add_column :status, String, size: 50, null: true
      add_column :title, String, size: 255, null: true
      add_column :number, Integer, null: true
      add_column :github_created_at, DateTime, null: true
      add_column :github_updated_at, DateTime, null: true

      set_column_allow_null :person_id, true

      drop_constraint :github_issues_history_person_id_fkey
      drop_column :person_id

      add_foreign_key :person_id, :apex_people, type: :uuid, null: true
    end
  end

  down do
    alter_table(:github_issues) do
      drop_column :status
      drop_column :title
      drop_column :number
      drop_column :github_created_at
      drop_column :github_updated_at
    end

    alter_table(:github_issues_history) do
      drop_column :status
      drop_column :title
      drop_column :number
      drop_column :github_created_at
      drop_column :github_updated_at
    end
  end
end
