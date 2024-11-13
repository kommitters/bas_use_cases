# frozen_string_literal: true

require 'logger'
require 'bas/bot/review_media'
require_relative 'config'
require 'bas/shared_storage'

read_options = {
  connection: Config::CONNECTION,
  db_table: "review_images",
  tag: "ReviewMediaRequest"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "review_images",
  tag: "ReviewImage"
}

options = {
  secret: ENV.fetch("OPENAI_SECRET"),
  assistant_id: ENV.fetch("REVIEW_IMAGE_OPENAI_ASSISTANT"),
  media_type: "images"
}

begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::ReviewMedia.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
