# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module WorkLogs
      # WorkLogFormatter formats work log records for storage in a database.
      class WorkLogFormatter < Base
        def format # rubocop:disable Metrics/MethodLength
          {
            external_work_log_id: @record['id'],
            duration_minutes: (@record['duration'].to_f * 60).round,
            tags: format_tags(@record['tags']),
            person_id: @record['person_id'],
            project_id: @record['project_id'],
            activity_id: @record['activity_id'],
            work_item_id: @record['work_item_id'],
            creation_date: @record['inserted_at'],
            modification_date: @record['updated_at'],
            started_at: @record['started_at'],
            deleted: @record['deleted'],
            external: @record['external'],
            description: @record['description']
          }
        end
      end
    end
  end
end
