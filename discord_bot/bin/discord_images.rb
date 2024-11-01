# frozen_string_literal: true

require 'bundler/setup'
require_relative '../lib/discord_images'
require 'conversational_bots/bots/discord_bot'

# Load environment variables
DISCORD_BOT_TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')
connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

# Initialize bot commands and Discord bot, then start the bot
bot_commands = Bots::DiscordImages.new(connection)

# Use the full namespace for DiscordBot
discord_bot = DiscordBot.new(
  DISCORD_BOT_TOKEN,
  bot_commands.commands,
  bot_commands.method(:custom_handler)
)

begin
  discord_bot.start
rescue StandardError => e
  puts "Error starting the bot: #{e.message}"
end
