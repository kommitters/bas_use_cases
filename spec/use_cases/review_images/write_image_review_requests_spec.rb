# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/write_image_review_in_discord'

ENV['REVIEW_IMAGES_TABLE'] = 'REVIEW_IMAGES_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}.freeze

RSpec.describe Bot::WriteMediaReviewInDiscord do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'review_images',
      tag: 'ReviewImage'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'review_images',
      tag: 'WriteMediaReviewInDiscord'
    }

    options = {
      secret_token: "Bot #{ENV.fetch('DISCORD_BOT_TOKEN')}"
    }

    shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

    Bot::WriteMediaReviewInDiscord.new(options, shared_storage).execute
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::WriteMediaReviewRequests)

      allow(Bot::WriteMediaReviewRequests).to receive(:new).and_return(bas_bot)

      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
