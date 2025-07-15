# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/operaton/process_client'
require 'logger'

module Implementation
  ##
  # The Implementation::StartProcessInstance class consumes prepared input from shared storage
  # and starts a BPMN process instance in Operaton via the REST API.
  #
  # <b>Example</b>
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({
  #     read_options: {
  #       connection: Config::CONNECTION,
  #       db_table: 'operaton_created_instance',
  #       tag: 'PrepareStartInstance'
  #     },
  #     write_options: {
  #       connection: Config::CONNECTION,
  #       db_table: 'operaton_created_instance',
  #       tag: 'StartProcessInstance'
  #     }
  #   })
  #
  #   Implementation::StartProcessInstance.new({}, shared_storage).execute
  #
  class StartProcessInstance < ::Bas::Bot::Base
    def process
      data = read_response.data

      process_key = data['process_key']
      business_key = data['business_key']
      variables = data['variables'] || {}

      return { error: 'process_key is required' } unless process_key
      return { error: 'business_key is required' } unless business_key

      execute_creation(process_key, business_key, variables)
    end

    private

    def execute_creation(process_key, business_key, variables)
      log_instance_start(process_key, business_key)
      client = build_client
      response = start_instance(client, process_key, business_key, variables)
      success_response(response)
    rescue StandardError => e
      error_response(e)
    end

    def build_client
      Utils::Operaton::ProcessClient.new(
        base_url: ENV.fetch('OPERATON_BASE_URL') { raise 'OPERATON_BASE_URL environment variable is required' }
      )
    end

    def start_instance(client, process_key, business_key, variables)
      client.start_process_instance_by_key(
        process_key,
        business_key: business_key,
        variables: variables,
      )
    end

    def success_response(response)
      Logger.new($stdout).info("✅ Instance created successfully. ID: #{response['id']}")
      { success: response }
    end

    def error_response(error)
      Logger.new($stdout).error("❌ Error creating instance: #{error.message}")
      { error: error.message }
    end

    def log_instance_start(process_key, business_key)
      Logger.new($stdout).info("🚀 Starting instance of process '#{process_key}' " \
           "with business key '#{business_key}'")
    end
  end
end
