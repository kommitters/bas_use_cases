# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:github_releases) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      BigInt :external_github_release_id, null: false
      BigInt :repository_id, null: false
      String :name, size: 255, null: false
      String :tag_name, size: 255, null: true
      Boolean :is_prerelease, null: false, default: true
      DateTime :creation_timestamp, null: true
      DateTime :published_timestamp, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:github_releases)
  end
end
