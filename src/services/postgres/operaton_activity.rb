# frozen_string_literal: true

require_relative 'operaton_base'

module Services
  module Postgres
    ##
    # OperatonActivity Service for PostgreSQL
    #
    # Provides CRUD operations for the 'operaton_activities' table using the OperatonBase service.
    class OperatonActivity < Services::Postgres::OperatonBase
      ATTRIBUTES = %i[
        external_activity_id external_process_id process_definition_key
        activity_id activity_name activity_type task_id assignee
        start_time end_time duration_in_millis
      ].freeze

      TABLE = :operaton_activities
    end
  end
end
