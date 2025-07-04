# frozen_string_literal: true
puts `pwd`
require 'bas/infrastructure/operaton/external_task_client'

require 'bas/bot/base'

module Implementation
  class SendEmailFromOperaton < Bas::Bot::Base
    def process
      client = Bas::Infrastructure::Operaton::ExternalTaskClient.new(
        base_url: process_options[:operaton_base_url],
        worker_id: process_options[:worker_id]
      )

      puts '--> Buscando tareas de "send_email"...'
      tasks = client.fetch_and_lock('send_email')

      if tasks.empty?
        puts '... No hay tareas disponibles.'
        return { success: { message: 'No tasks available' } }
      end

      task = tasks.first
      puts "--> Tarea obtenida: #{task['id']}"
      puts "--> Variables: #{task['variables']}"

      # Aquí iría la lógica real para enviar el email.
      # Por ahora, solo simulamos el éxito.
      result_variables = {
        message: "Email procesado y enviado exitosamente desde SendEmailFromOperaton.",
        send_timestamp: Time.now.utc.iso8601,
        processed_by: self.class.name
      }

      client.complete(task['id'], result_variables)
      puts "--> Tarea completada exitosamente con resultado: #{result_variables.inspect}"

      { success: { task_id: task['id'], result: result_variables } }
    rescue StandardError => e
      puts "ERROR: #{e.message}"
      # En un caso real, aquí se podría usar client.report_failure
      { error: { message: e.message, backtrace: e.backtrace } }
    end
  end
end
