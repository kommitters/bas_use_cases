# frozen_string_literal: true

require 'bundler/setup'
require 'conversational_bots/bots/telegram_bot'
require_relative '../lib/web_availability'

# Configuration variables
TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')
connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

# Initialize bot commands and create an instance of the Telegram bot
bot_commands = Bots::WebAvailability.new(connection)

# Define bot commands after instantiating the object
bot_commands.define_commands

# Create the TelegramBot object with the defined commands
telegram_bot = TelegramBot.new(
  TELEGRAM_BOT_TOKEN,
  bot_commands.commands,
  bot_commands.method(:custom_handler)
)

# Start the bot
begin
  telegram_bot.start
rescue StandardError => e
  puts "Error in Telegram Bot: #{e.message}"
ensure
  puts 'Telegram bot stopped, exiting the program.'
end
