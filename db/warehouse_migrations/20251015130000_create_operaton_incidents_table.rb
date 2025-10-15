# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:operaton_incidents) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_incident_id, size: 255, null: false, unique: true
      foreign_key :external_process_id, :operaton_processes, key: :external_process_id, type: 'varchar(255)'
      String :process_definition_key, size: 255
      String :activity_id, size: 255
      String :incident_type, size: 255
      String :incident_message, text: true
      TrueClass :resolved
      DateTime :create_time
      DateTime :end_time
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:operaton_incidents)
  end
end
