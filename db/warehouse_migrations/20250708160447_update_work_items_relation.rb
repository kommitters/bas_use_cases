# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:work_items) do
      add_foreign_key :github_issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
    end
  end

  down do
    alter_table(:work_items) do
      drop_foreign_key :github_issue_id
      drop_column :github_issue_id
    end
  end
end
