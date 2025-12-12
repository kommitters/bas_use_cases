# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:github_repositories_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      foreign_key :github_repository_id, :github_repositories, type: :uuid, null: false
      String :external_repository_id, null: false # Native GitHub ID
      String :name, size: 255, null: false
      String :organization, size: 100, null: false
      String :url, size: 255, null: true
      Boolean :is_private, null: true
      Boolean :is_archived, null: true

      # Synchronization Cursors (Semaphores for Workers)
      # These track the last time a specific entity was synced for this repo.
      DateTime :last_synced_issues_at, null: true
      DateTime :last_synced_releases_at, null: true
      DateTime :last_synced_pull_requests_at, null: true

      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')

      # Indices to optimize Worker queries
      index :organization
      index :last_synced_issues_at
      index :last_synced_releases_at
      index :last_synced_pull_requests_at
    end
  end

  down do
    drop_table(:github_repositories_history)
  end
end
