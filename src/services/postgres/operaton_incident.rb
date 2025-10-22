# frozen_string_literal: true

require_relative 'operaton_base'

module Services
  module Postgres
    ##
    # OperatonIncident Service for PostgreSQL
    #
    # Provides CRUD operations for the 'operaton_incidents' table using the OperatonBase service.
    class OperatonIncident < Services::Postgres::OperatonBase
      ATTRIBUTES = %i[
        external_incident_id external_process_id process_definition_key
        activity_id incident_type incident_message resolved
        create_time end_time
      ].freeze

      TABLE = :operaton_incidents
    end
  end
end
