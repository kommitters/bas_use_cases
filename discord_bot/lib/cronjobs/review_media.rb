# frozen_string_literal: true

require 'logger'
require_relative '../../../src/implementations/review_image'
require_relative 'config'
require 'bas/shared_storage/postgres'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'review_images',
  tag: 'ReviewMediaRequest'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'review_images',
  tag: 'ReviewImage'
}

options = {
  secret: ENV.fetch('OPENAI_SECRET'),
  assistant_id: ENV.fetch('REVIEW_IMAGE_OPENAI_ASSISTANT'),
  media_type: 'images'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::ReviewMedia.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
