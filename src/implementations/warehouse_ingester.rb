# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../services/postgres/project'
require_relative '../services/postgres/activity'
require_relative '../services/postgres/work_item'
require_relative '../services/postgres/domain'
require_relative '../services/postgres/person'

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
      'project' => { klass: Services::Postgres::Project, external_key: 'external_project_id' },
      'activity' => { klass: Services::Postgres::Activity, external_key: 'external_activity_id' },
      'work_item' => { klass: Services::Postgres::WorkItem, external_key: 'external_work_item_id' },
      'domain' => { klass: Services::Postgres::Domain, external_key: 'external_domain_id' },
      'person' => { klass: Services::Postgres::Person, external_key: 'external_person_id' }
    }.freeze

    def process
      return { success: { notification: '' } } if unprocessable_response

      data = read_response.data
      type = data['type']
      return { success: { processed: 0 } } unless type && SERVICES[type]

      process_items(type, data['content'])
    end

    private

    def process_items(type, content)
      config = SERVICES[type]
      service = config[:klass].new(process_options[:db])
      processed = 0
      Array(content).each do |item|
        upsert(service, item, config[:external_key], type)
        processed += 1
      end
      { success: { processed: processed } }
    end

    def upsert(service, item, external_key, type)
      external_id = item[external_key]
      found = service.query({ external_key.to_sym => external_id }).first
      item['updated_at'] = Time.now.utc
      persist(service, found, item)
    rescue StandardError => e
      puts "[WarehouseIngester ERROR][#{type}] #{e.class}: #{e.message}"
    end

    def persist(service, found, item)
      if found
        service.update(found[:id], item)
      else
        service.insert(item)
      end
    end
  end
end
