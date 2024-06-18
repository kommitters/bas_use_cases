# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/support_email/notify_support_emails'

ENV['SUPPORT_EMAIL_DISCORD_WEBHOOK'] = 'SUPPORT_EMAIL_DISCORD_WEBHOOK'
ENV['DISCORD_BOT_NAME'] = 'DISCORD_BOT_NAME'
ENV['SUPPORT_EMAIL_TABLE'] = 'SUPPORT_EMAIL_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Notify::SupportEmails do
  before do
    params = {
      discord_webhook: ENV.fetch('SUPPORT_EMAIL_DISCORD_WEBHOOK'),
      discord_bot_name: ENV.fetch('DISCORD_BOT_NAME'),
      table_name: ENV.fetch('SUPPORT_EMAIL_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Notify::SupportEmails.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::NotifyDiscord)

      allow(Bot::NotifyDiscord).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
