# frozen_string_literal: true

require 'time'
require '../bas/lib/bas/bot/base'
require '../bas/lib/bas/utils/operaton/external_task_client'

module Implementation
  ##
  # The Implementation::CompleteOperatonTask class is the final bot in the chain.
  # It reads a processed task from the shared storage and calls the Operaton API
  # to complete the external service task, effectively closing the loop.
  #
  class CompleteOperatonTask < Bas::Bot::Base
    # Process function to complete the task in Operaton.
    #
    def process
      # The bot framework provides the record from the worker bot.
      processed_data = read_response.data
      original_task = processed_data['original_task_data']
      result_vars = processed_data['result_variables']

      unless original_task && result_vars
        return { success: { message: "Ignoring malformed record." } }
      end

      original_task_data = original_task['task_data']
      worker_id = original_task_data['workerId']

      puts "--> [Completer] Finalizando tarea: #{original_task_data['id']} (Topic: #{original_task_data['topicName']}) usando el workerId: #{worker_id}"

      client = Bas::Utils::Operaton::ExternalTaskClient.new(
        base_url: @process_options[:operaton_base_url],
        worker_id:
      )

      client.complete(original_task_data['id'], result_vars)

      puts "--> [Completer] Tarea completada exitosamente en Operaton."

      # The returned payload is the final record for auditing purposes.
      { success: { completed_task_id: original_task['task_id'], completed_at: Time.now.utc.iso8601, original_record_id: read_response.id } }
    rescue StandardError => e
      puts "--> [Completer] ERROR: #{e.message}"
      # Here we could implement a retry mechanism or report the failure to Operaton.
      { error: { message: e.message, backtrace: e.backtrace } }
    end
  end
end
