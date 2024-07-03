# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/review_images/review_image'

ENV['OPENAI_SECRET'] = 'OPENAI_SECRET'
ENV['REVIEW_IMAGE_OPENAI_ASSISTANT'] = 'REVIEW_IMAGE_OPENAI_ASSISTANT'
ENV['REVIEW_IMAGES_TABLE'] = 'REVIEW_IMAGES_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Review::Image do
  before do
    params = {
      openai_secret: ENV.fetch('OPENAI_SECRET'),
      openai_assistant: ENV.fetch('REVIEW_IMAGE_OPENAI_ASSISTANT'),
      table_name: ENV.fetch('REVIEW_IMAGES_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Review::Image.new(params)
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
