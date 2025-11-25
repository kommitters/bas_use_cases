# frozen_string_literal: true

require 'json'
require 'date'

require_relative '../../utils/apex/apex_get_general'
require_relative 'pto_filter'

# Shared storage
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromApex'
}

# Fetch APEX
begin
  response = ApexClient.get(endpoint: 'taskman_pto')
rescue StandardError => e
  puts "ERROR APEX GET: #{e.message}"
  exit
end

raw = response.body.to_s
decoded = raw.dup.force_encoding('UTF-8')
unless decoded.valid_encoding?
  decoded = raw.encode(
    'UTF-8', 'binary',
    invalid: :replace,
    undef: :replace,
    replace: '?'
  )
end

# Parse JSON
begin
  json = JSON.parse(decoded)
rescue StandardError => e
  puts "JSON ERROR: #{e.message}"
  exit
end

items = json['items'] || []

# Filter TODAY
today_ptos = PtoFilter.filter_today(items)

# Convert entries → messages
messages = today_ptos.map { |entry| PtoFilter.format_message(entry) }

# Build output
result = { 'ptos' => messages }

# WRITE result to Shared Storage
begin
  writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
  writer.write(success: result)
  puts "\nStored to shared storage successfully."
rescue StandardError => e
  puts "\nERROR writing to shared storage:"
  puts e.message
end
