# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:github_issues) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      BigInt :external_github_issue_id, null: false, unique: true
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      BigInt :repository_id, null: false
      BigInt :milestone_id, null: true
      column :assignees, 'text[]', null: true
      column :labels, 'text[]', null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:github_issues)
  end
end
