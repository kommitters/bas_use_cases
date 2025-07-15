# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/operaton/external_task_client'
require 'logger'

module Implementation
  ##
  # The Implementation::PollOperatonTasks class serves as a bot implementation to poll Operaton
  # for any available external service tasks, lock them, and store them in the shared storage
  # for other worker bots to process.
  #
  # Example
  #  write_options = {
  #  connection: Config::CONNECTION,
  #  db_table: 'operaton_tasks',
  #  tag: 'OperatonTaskPolled'
  # }
  #
  #  options = {
  #   operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  #   worker_id: ENV.fetch('OPERATON_POLLER_WORKER_ID', "operaton_poller_#{Time.now.to_i}"),
  #  # We can add a list of topics to poll in the future from an ENV var:
  #   topics: ENV.fetch('OPERATON_TOPICS', 'send_email,variables').split(',')
  #   topics: 'send_email,variables'
  #  }
  #
  ## Process bot
  # begin
  #  shared_storage_reader = Bas::SharedStorage::Default.new
  #  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::PollOperatonTasks.new(options, shared_storage_reader, shared_storage_writer).execute
  # rescue StandardError => e
  #  Logger.new($stdout).info(e.message)
  # end
  class PollOperatonTasks < Bas::Bot::Base
    def process
      client = build_client
      task = search_and_lock_tasks(client)

      return error_response('No tasks available') if task.nil? || task.empty?

      Logger.new($stdout).info("--> [Poller] Task obtained and locked: #{task['id']} (Topic: #{task['topicName']})")

      success_response(normalize_task(task))
    rescue StandardError => e
      Logger.new($stdout).info("[Poller] Unexpected error during polling: #{e.message}")
      error_response(e.message)
    end

    private

    def build_client
      puts '--> [Poller] Searching for any available task in Operaton...'

      Utils::Operaton::ExternalTaskClient.new(
        base_url: process_options[:operaton_base_url],
        worker_id: process_options[:worker_id]
      )
    end

    def search_and_lock_tasks(client)
      tasks = client.fetch_and_lock(process_options[:topics], max_tasks: 1)
      tasks.first unless tasks.empty?
    end

    def normalize_task(task)
      {
        task_id: task['id'],
        topic_name: task['topicName'],
        task_data: task
      }
    end

    def success_response(result)
      { success: result }
    end

    def error_response(message)
      { error: { message: message } }
    end
  end
end
