# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:weekly_scopes) do
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
      add_foreign_key :person_id, :persons, type: :uuid, null: true
    end
  end

  down do
    alter_table(:weekly_scopes) do
      drop_foreign_key :domain_id
      drop_foreign_key :person_id
    end
  end
end
