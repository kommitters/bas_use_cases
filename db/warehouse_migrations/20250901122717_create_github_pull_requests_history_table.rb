# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:github_pull_requests_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      BigInt :external_github_pull_request_id, null: false
      foreign_key :pull_request_id, :github_pull_requests, null: false, on_delete: :cascade, type: :uuid
      foreign_key :release_id, :github_releases, type: :uuid, null: true, on_delete: :cascade
      foreign_key :issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      BigInt :repository_id, null: false
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
    drop_table(:github_pull_requests_history)
  end
end
