# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/review_text/write_text_review_in_notion'

ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['REVIEW_TEXT_TABLE'] = 'REVIEW_TEXT_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Write::TextReviewInNotion do
  before do
    params = {
      notion_secret: ENV.fetch('NOTION_SECRET'),
      table_name: ENV.fetch('REVIEW_TEXT_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Write::TextReviewInNotion.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::WriteMediaReviewInNotion)

      allow(Bot::WriteMediaReviewInNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
