# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/review_images/write_image_review_requests'

# Configuration
params = {
  notion_secret: ENV.fetch('NOTION_SECRET'),
  table_name: ENV.fetch('REVIEW_IMAGES_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Write::ImageReviewRequests.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
