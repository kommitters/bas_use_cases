# frozen_string_literal: true

require 'dotenv/load'
require_relative '../implementations/send_email_from_operaton'


options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  worker_id: ENV.fetch('OPERATON_WORKER_ID', "send_email_worker_#{Time.now.to_i}")
}

puts "Iniciando el worker con la siguiente configuración:"
puts "URL Base de Operaton: #{options[:operaton_base_url]}"
puts "ID del Worker: #{options[:worker_id]}"
puts "-------------------------------------------------"

# --- Ejecución ---
# Se instancia la implementación sin shared_storage (nil) porque este
# worker es autónomo por ahora.
worker = Implementation::SendEmailFromOperaton.new(options, nil)

# El método `execute` es provisto por `Bas::Bot::Base` y llama
# internamente al método `process` que definimos.
result = worker.execute

puts "-------------------------------------------------"
puts "Resultado de la ejecución:"
puts result.inspect
