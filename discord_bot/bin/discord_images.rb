# frozen_string_literal: true

require 'bundler/setup'
require_relative '../lib/discord_images'
require 'conversational_bots/bots/discord_bot'

# Load environment variables
DISCORD_BOT_TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')
db_user = ENV.fetch('POSTGRES_USER')
db_password = ENV.fetch('POSTGRES_PASSWORD')
db_host = ENV.fetch('DB_HOST')
db_port = ENV.fetch('DB_PORT')
db_name = ENV.fetch('POSTGRES_DB')
DB_CONNECTION_STRING = "postgresql://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}".freeze

# Initialize bot commands and Discord bot, then start the bot
bot_commands = Bots::DiscordImages.new(DB_CONNECTION_STRING)
discord_bot = DiscordBot.new(
  DISCORD_BOT_TOKEN,
  bot_commands.commands,
  bot_commands.method(:custom_handler)
)

begin
  discord_bot.start
rescue StandardError => e
  puts "Error al iniciar el bot: #{e.message}"
end
