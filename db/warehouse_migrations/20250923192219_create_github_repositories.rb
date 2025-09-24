# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  up do
    create_table(:github_repositories) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      BigInt :external_github_repository_id, null: false
      String :name, null: false
      String :language, null: true
      String :description, null: true
      String :html_url, null: true

      Boolean :is_private, null: false, default: false
      Boolean :is_fork, null: false, default: false
      Boolean :is_archived, null: false, default: false
      Boolean :is_disabled, null: false, default: false

      Integer :watchers_count, null: false, default: 0
      Integer :stargazers_count, null: false, default: 0
      Integer :forks_count, null: false, default: 0

      jsonb :owner, null: true

      DateTime :creation_timestamp, null: false

      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')

      index :external_github_repository_id, unique: true
      index :name
      index :creation_timestamp
    end
  end

  down do
    drop_table(:github_repositories)
  end
end
