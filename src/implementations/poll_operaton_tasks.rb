# frozen_string_literal: true

require 'bas/bot/base'
require '../bas/lib/bas/utils/operaton/external_task_client'

module Implementation
  ##
  # The Implementation::PollOperatonTasks class serves as a bot implementation to poll Operaton
  # for any available external service tasks, lock them, and store them in the shared storage
  # for other worker bots to process.
  #
  class PollOperatonTasks < Bas::Bot::Base
    # Process function to fetch, lock, and store an Operaton task.
    #
    def process
      client = polling
      task = search_and_lock_tasks(client)

      if task.nil? || task.empty?
        puts '--> [Poller] No hay tareas disponibles.'
        return { error: { message: 'No tasks available' } }
      end

      puts "--> [Poller] Tarea obtenida y bloqueada: #{task['id']} (Topic: #{task['topicName']})"

      normalized_task = normalize_task(task)
      { success: normalized_task }
    end

    private

    def normalize_task(task)
      {
        task_id: task['id'],
        topic_name: task['topicName'],
        task_data: task
      }
    end

    def polling
      puts '--> [Poller] Buscando cualquier tarea disponible en Operaton...'
      Bas::Utils::Operaton::ExternalTaskClient.new(
        base_url: @process_options[:operaton_base_url],
        worker_id: @process_options[:worker_id]
      )
    end

    def search_and_lock_tasks(client)
      tasks = client.fetch_and_lock(@process_options[:topics], max_tasks: 1)

      return nil if tasks.empty?

      tasks.first
    end
  end
end
