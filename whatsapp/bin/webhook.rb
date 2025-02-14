# frozen_string_literal: true

require 'bas/shared_storage/postgres'
require 'sinatra'
require 'json'

require_relative '../formatter/whatsapp'

# SINATRA CONFIG
set :server, :puma
set :bind, '0.0.0.0'
set :environment, :development

TOKEN = ENV.fetch('WHATSAPP_WEBHOOK_TOKEN')

# SERVICES
write_options = {
  connection: {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  },
  db_table: 'observed_websites_availability',
  tag: 'WhatsappWebhook'
}

base_formatter = Formatter::WhatsApp.new
shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)

# SINATRA ENDPOINTS
get '/webhook' do
  challenge = params['hub.challenge']
  verification_token = params['hub.verify_token']

  if verification_token == TOKEN
    status 200
    body challenge
  else
    status 403
  end
end

post '/webhook' do
  request_body = request.body.read
  data = JSON.parse(request_body)

  begin
    data = base_formatter.process(data)
    shared_storage.write(success: data) unless data[:conversation_id].nil?
  rescue StandardError => e
    logger.error "Failed to process message: #{e.message}"
    status 500
    body 'Internal Server Error'
  end

  status 200
end
