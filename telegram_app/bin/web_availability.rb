# frozen_string_literal: true

require 'bundler/setup'
require 'conversational_bots/bots/telegram_bot'
require_relative '../lib/web_availability'

# Configuration variables
TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')
db_user = ENV.fetch('POSTGRES_USER')
db_password = ENV.fetch('POSTGRES_PASSWORD')
db_host = ENV.fetch('DB_HOST')
db_port = ENV.fetch('DB_PORT')
db_name = ENV.fetch('POSTGRES_DB')
connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}
DB_CONNECTION_STRING = "postgresql://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}".freeze

# Initialize bot commands and create an instance of the Telegram bot
bot_commands = Bots::WebAvailability.new(connection)
bot_commands.define_commands

# bot_commands.define_commands
telegram_bot = TelegramBot.new(
  TELEGRAM_BOT_TOKEN,
  bot_commands.commands,
  bot_commands.method(:custom_handler)
)

# Start the bot directly
begin
  telegram_bot.start
rescue StandardError => e
  puts "Error in Telegram Bot: #{e.message}"
end

puts 'Telegram bot stopped, exiting the program.'
