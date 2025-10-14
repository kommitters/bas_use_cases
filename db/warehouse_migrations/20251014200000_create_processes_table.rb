# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:processes) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_process_id, size: 255, null: false
      String :business_key, size: 255
      String :process_definition_key, size: 255
      String :process_definition_name, size: 255
      DateTime :start_time
      DateTime :end_time
      Bignum :duration_in_millis
      Integer :process_definition_version
      String :state, size: 100
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:processes)
  end
end
