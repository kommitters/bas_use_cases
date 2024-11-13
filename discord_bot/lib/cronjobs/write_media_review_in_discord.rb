# frozen_string_literal: true

require 'logger'
require 'bas/bot/write_media_review_in_discord'
require 'bas/shared_storage'
require_relative 'config'

read_options = {
  connection: Config::CONNECTION,
  db_table: "review_images",
  tag: "ReviewImage"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "review_images",
  tag: "WriteMediaReviewInDiscord"
}

options = {
  secret_token: "Bot #{ENV.fetch('DISCORD_BOT_TOKEN')}"
}

begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::WriteMediaReviewInDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
