# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/review_image'

ENV['OPENAI_SECRET'] = 'OPENAI_SECRET'
ENV['REVIEW_IMAGE_OPENAI_ASSISTANT'] = 'REVIEW_IMAGE_OPENAI_ASSISTANT'
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

RSpec.describe Bot::ReviewMedia do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'review_images',
      tag: 'ReviewMediaRequest'
    }

    write_options = {
      connection: CONNECTION,
      db_table: 'review_images',
      tag: 'ReviewImage'
    }

    options = {
      secret: ENV.fetch('OPENAI_SECRET'),
      assistant_id: ENV.fetch('REVIEW_IMAGE_OPENAI_ASSISTANT'),
      media_type: 'images'
    }

    shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

    Bot::ReviewMedia.new(options, shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::ReviewMedia)

      allow(Bot::ReviewMedia).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
