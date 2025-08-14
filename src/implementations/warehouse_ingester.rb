# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../services/postgres/activity'
require_relative '../services/postgres/document'
require_relative '../services/postgres/document_activity_log'
require_relative '../services/postgres/domain'
require_relative '../services/postgres/key_result'
require_relative '../services/postgres/milestone'
require_relative '../services/postgres/person'
require_relative '../services/postgres/project'
require_relative '../services/postgres/weekly_scope'
require_relative '../services/postgres/work_item'
require_relative '../services/postgres/work_log'
require_relative '../services/postgres/github_release'
require_relative '../services/postgres/github_issue'
require_relative '../services/postgres/github_pull_request'
require_relative '../services/postgres/kpi'

module Implementation
  ##
  # The Implementation::WarehouseIngester class is a bot that reads records from
  # shared Postgres storage and uses the appropriate Postgres service to insert or update
  # records based on their type.
  #
  # It supports dynamic entity types such as `project`, `activity`, `work_item`, `domain`, and `person`,
  # using corresponding services to perform the necessary database operations.
  #
  # <br>
  # <b>Example</b>
  #
  # array = PG::TextEncoder::Array.new.encode(
  #   %w[FetchWorkItemsFromNotionDatabase FetchProjectsFromNotionDatabase FetchActivitiesFromNotionDatabase]
  # )

  # read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'warehouse_sync',
  #   where: 'archived=$1 AND tag=ANY($2) AND stage=$3 ORDER BY inserted_at DESC',
  #   params: [false, array, 'unprocessed']
  # }

  # write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'warehouse_sync',
  #   tag: 'WarehouseSyncProcessed'
  # }

  # options = {
  #   db: Config::CONNECTION
  # }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::WarehouseIngester.new(options, shared_storage).execute
  #
  class WarehouseIngester < Bas::Bot::Base
    SERVICES = {
      'activity' => { service: Services::Postgres::Activity, external_key: 'external_activity_id' },
      'document' => { service: Services::Postgres::Document, external_key: 'external_document_id' },
      'document_activity_log' => {
        service: Services::Postgres::DocumentActivityLog, external_key: 'unique_identifier'
      },
      'domain' => { service: Services::Postgres::Domain, external_key: 'external_domain_id' },
      'key_result' => { service: Services::Postgres::KeyResult, external_key: 'external_key_result_id' },
      'milestone' => { service: Services::Postgres::Milestone, external_key: 'external_milestone_id' },
      'person' => { service: Services::Postgres::Person, external_key: 'external_person_id' },
      'project' => { service: Services::Postgres::Project, external_key: 'external_project_id' },
      'weekly_scope' => { service: Services::Postgres::WeeklyScope, external_key: 'external_weekly_scope_id' },
      'work_item' => { service: Services::Postgres::WorkItem, external_key: 'external_work_item_id' },
      'work_log' => { service: Services::Postgres::WorkLog, external_key: 'external_work_log_id' },
      'github_release' => { service: Services::Postgres::GithubRelease, external_key: 'external_github_release_id' },
      'github_issue' => { service: Services::Postgres::GithubIssue, external_key: 'external_github_issue_id' },
      'github_pull_request' => {
        service: Services::Postgres::GithubPullRequest, external_key: 'external_github_pull_request_id'
      },
      'kpi' => { service: Services::Postgres::Kpi, external_key: 'external_kpi_id' }

    }.freeze

    def process
      return { success: { processed: 0 } } if unprocessable_response

      @type = read_response.data['type']
      return { success: { processed: 0 } } unless @type && SERVICES[@type]

      config = SERVICES[@type]
      @external_key = config[:external_key]
      @service = config[:service].new(process_options[:db])

      process_items
    end

    private

    def process_items
      processed = 0
      read_response.data['content'].each do |item|
        upsert(item)
        processed += 1
      end

      { success: { processed: processed } }
    end

    def upsert(item)
      external_id = item[@external_key]
      found = @service.query({ @external_key.to_sym => external_id }).first
      persist(found, item)
    rescue StandardError => e
      puts "[WarehouseIngester ERROR][#{@type}] #{e.class}: #{e.message}"
    end

    def persist(found, item)
      if found
        @service.update(found[:id], item)
      else
        @service.insert(item)
      end
    end
  end
end
