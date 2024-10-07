# frozen_string_literal: true

require 'logger'
require 'bas/bot/review_media'
puts "IN RM"

connection = {
  host: 'bas_db',
  port: '5432',
  dbname: 'bas',
  user: 'admin',
  password: 'WzxuH87TADlaGd49VGcP'
}

options = {
  read_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewMediaRequest'
  },
  process_options: {
    openai_secret: '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',
    openai_assistant: 'asst_mjRHSJH23rsunYzVgOAnxImf',
    secret: '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',
    assistant_id: 'asst_mjRHSJH23rsunYzVgOAnxImf',
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
