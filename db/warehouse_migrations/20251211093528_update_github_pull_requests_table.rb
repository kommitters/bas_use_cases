# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:github_pull_requests) do
      drop_column :repository_id

      add_foreign_key :repository_id, :github_repositories, type: :uuid, null: true
      add_foreign_key :person_id, :apex_people, type: :uuid, null: true
    end

    alter_table(:github_pull_requests_history) do
      drop_column :repository_id

      add_foreign_key :repository_id, :github_repositories, type: :uuid, null: true
      add_foreign_key :person_id, :apex_people, type: :uuid, null: true
    end
  end

  down do
    alter_table(:github_pull_requests) do
      drop_foreign_key :repository_id
      drop_foreign_key :person_id

      add_column :repository_id, BigInt, null: true
    end

    alter_table(:github_pull_requests_history) do
      drop_foreign_key :person_id
      drop_foreign_key :repository_id

      add_column :repository_id, BigInt, null: true
    end
  end
end
