# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:github_releases) do
      drop_column :repository_id

      add_foreign_key :repository_id, :github_repositories, type: :uuid, null: true
    end

    alter_table(:github_releases_history) do
      drop_column :repository_id

      add_foreign_key :repository_id, :github_repositories, type: :uuid, null: true
    end
  end

  down do
    alter_table(:github_releases) do
      drop_foreign_key :repository_id

      add_column :repository_id, BigInt, null: true
    end

    alter_table(:github_releases_history) do
      drop_foreign_key :repository_id

      add_column :repository_id, BigInt, null: true
    end
  end
end
