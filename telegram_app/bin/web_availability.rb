# frozen_string_literal: true

require 'dotenv/load' # Load environment variables
require 'conversational_bots/bots/telegram_bot' # Load the conversational_bots gem
require_relative '../lib/web_availability' # Load the web_availability.rb file

# Configuration variables
TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DB_CONNECTION_STRING = ENV['DB_CONNECTION_STRING']

# Initialize commands for the bot
bot_commands = Bots::WebAvailability.new(DB_CONNECTION_STRING)

# Create an instance of the Telegram bot from the gem, specifying the custom handler
telegram_bot = TelegramBot.new(
  TELEGRAM_BOT_TOKEN,
  bot_commands.commands,
  bot_commands.method(:custom_handler) # Specify the custom handler correctly
)
# Run the bot in a separate thread
thread = Thread.new do
  telegram_bot.start # Ensure the start method is defined
rescue StandardError => e
  puts "Error in Telegram Bot: #{e.message}"
end

# Wait for the thread to finish
thread.join

puts 'Telegram bot stopped, exiting the program.'
