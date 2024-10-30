# frozen_string_literal: true

require_relative '../lib/discord_images'
require 'conversational_bots/bots/discord_bot'
require 'dotenv/load'

# Load environment variables
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']
DB_CONNECTION_STRING = ENV['DB_CONNECTION_STRING']

# Ensure mandatory configuration is present
if DISCORD_BOT_TOKEN.nil? || DB_CONNECTION_STRING.nil?
  raise 'Missing DISCORD_TOKEN or DB_CONNECTION_STRING in environment'
end

# Discord bot execution module
module DiscordImages
  def self.run
    bot_commands = initialize_bot_commands
    discord_bot = initialize_discord_bot(bot_commands)
    discord_bot.start # Start the bot directly
  end

  def self.initialize_bot_commands
    Bots::DiscordImages.new(DB_CONNECTION_STRING)
  rescue StandardError => e
    puts "Failed to initialize bot commands: #{e.message}"
    raise
  end

  def self.initialize_discord_bot(bot_commands)
    DiscordBot.new(
      DISCORD_BOT_TOKEN,
      bot_commands.commands,
      bot_commands.method(:custom_handler)
    )
  rescue StandardError => e
    puts "Failed to initialize Discord bot: #{e.message}"
    raise
  end
end

# Start the bot
DiscordImages.run
