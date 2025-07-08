# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:github_pull_requests) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      BigInt :external_github_pull_request_id, size: 255, null: false
      BigInt :repository_id, null: false
      foreign_key :release_id, :github_releases, type: :uuid, null: true, on_delete: :cascade
      foreign_key :issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      column :related_issue_ids, 'bigint[]', null: true
      column :reviews_data, :jsonb, null: true
      String :title, size: 255, null: false
      DateTime :creation_date, null: false
      DateTime :merge_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:github_pull_requests)
  end
end
