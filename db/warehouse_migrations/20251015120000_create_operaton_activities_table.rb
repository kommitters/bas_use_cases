# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:operaton_activities) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_activity_id, size: 255, null: false, unique: true
      String :external_process_id, size: 255, null: false
      String :process_definition_key, size: 255
      String :activity_id, size: 255
      String :activity_name
      String :activity_type
      String :task_id, size: 255
      String :assignee
      DateTime :start_time
      DateTime :end_time
      Bignum :duration_in_millis
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:operaton_activities)
  end
end
