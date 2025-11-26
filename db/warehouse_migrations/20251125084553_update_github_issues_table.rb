# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:github_issues) do
      add_column :status, String, size: 50, null: true
      add_column :title, String, size: 255, null: false
      add_column :number, Integer, null: false
    end

    alter_table(:github_issues_history) do
      add_column :status, String, size: 50, null: true
      add_column :title, String, size: 255, null: false
      add_column :number, Integer, null: false
    end
  end

  down do
    alter_table(:github_issues) do
      drop_column :status
      drop_column :title
      drop_column :number
    end

    alter_table(:github_issues_history) do
      drop_column :status
      drop_column :title
      drop_column :number
    end
  end
end
