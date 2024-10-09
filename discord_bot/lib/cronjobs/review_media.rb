# frozen_string_literal: true

require 'logger'
require 'bas/bot/review_media'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: 'bas',
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  read_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewMediaRequest'
  },
  process_options: {
    secret: ENV.fetch('OPENAI_SECRET'),
    assistant_id: ENV.fetch('OPENAI_ASSISTANT_ID'),
    media_type: 'images'
  },
  write_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewImage'
  }
}

begin
  bot = Bot::ReviewMedia.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
