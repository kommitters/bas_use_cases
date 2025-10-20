# frozen_string_literal: true

require_relative 'operaton_base'

module Services
  module Postgres
    ##
    # Process Service for PostgreSQL
    #
    # Provides CRUD operations for the 'operaton_processes' table using the OperatonBase service.
    class OperatonProcess < Services::Postgres::OperatonBase
      ATTRIBUTES = %i[
        external_process_id business_key process_definition_key
        process_definition_name start_time end_time duration_in_millis
        process_definition_version state
      ].freeze

      TABLE = :operaton_processes
    end
  end
end
