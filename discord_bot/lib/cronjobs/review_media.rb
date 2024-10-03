# frozen_string_literal: true

require 'logger'
require 'bas/bot/review_media'

connection = {
  openai_secret: ENV.fetch('OPENAI_SECRET'),
  openai_assistant: ENV.fetch('OPENAI_ASSISTANT_ID'),
  table_name: 'review_images',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  read_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewMediaRequest'
  },
  process_options: {
    secret: ENV.fetch('OPENAI_SECRET'),
    assistant_id:  ENV.fetch('OPENAI_ASSISTANT_ID'),
    media_type: 'images'
  },
  write_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewText'
  }
}

begin
  bot = Bot::ReviewMedia.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
