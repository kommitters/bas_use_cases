# frozen_string_literal: true

require 'json'
require 'date'

load File.expand_path('../../utils/apex/apex_get_general.rb', __dir__)
load File.expand_path('pto_filter.rb', __dir__)

# Shared storage
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

WRITE_OPTIONS = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromGoogle'
}

# 1. Fetch APEX
begin
  response = ApexClient.get(endpoint: "taskman_pto")
rescue => e
  puts "ERROR APEX GET: #{e.message}"
  exit
end

raw = response.body.to_s
decoded = raw.dup.force_encoding("UTF-8")
decoded = raw.encode(
  "UTF-8", "binary",
  invalid: :replace,
  undef: :replace,
  replace: "?"
) unless decoded.valid_encoding?

# ------------------------------------------------------------
# 2. Parse JSON
# ------------------------------------------------------------
begin
  json = JSON.parse(decoded)
rescue => e
  puts "JSON ERROR: #{e.message}"
  puts decoded
  exit
end

items = json["items"] || []
puts "TOTAL PTOs: #{items.length}"

# ------------------------------------------------------------
# 3. Filter TODAY
# ------------------------------------------------------------
today_ptos = PtoFilter.filter_today(items)

# ------------------------------------------------------------
# 4. Convert entries → messages
# ------------------------------------------------------------
messages = today_ptos.map { |entry| PtoFilter.format_message(entry) }

# ------------------------------------------------------------
# 5. Build output
# ------------------------------------------------------------
result = { "ptos" => messages }

puts "\n=== PTOs TODAY (formatted) ==="
puts JSON.pretty_generate(result)

# ------------------------------------------------------------
# 6. WRITE result to Shared Storage
# ------------------------------------------------------------
begin
  writer = Bas::SharedStorage::Postgres.new(write_options: WRITE_OPTIONS)
  writer.write(success: result)
  puts "\nStored to shared storage successfully."
rescue => e
  puts "\nERROR writing to shared storage:"
  puts e.message
end
