# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:documents) do
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
    end
  end

  down do
    alter_table(:documents) do
      drop_foreign_key :domain_id
    end
  end
end
