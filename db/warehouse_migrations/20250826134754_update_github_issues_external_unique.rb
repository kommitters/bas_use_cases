# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:github_issues) do
      drop_constraint 'github_issues_external_github_issue_id_key'
    end
  end

  down do
    alter_table(:github_issues) do
      add_constraint 'github_issues_external_github_issue_id_key',
                     type: :unique,
                     columns: [:external_github_issue_id]
    end
  end
end
