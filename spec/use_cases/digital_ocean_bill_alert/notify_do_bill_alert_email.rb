# frozen_string_literal: true

require 'rspec'
require_relative '../../use_cases/digital_ocean_bill_alert/notify_do_bill_alert_email'

ENV['DIGITAL_OCEAN_REFRESH_TOKEN'] = 'DIGITAL_OCEAN_REFRESH_TOKEN'
ENV['DIGITAL_OCEAN_CLIENT_ID'] = 'DIGITAL_OCEAN_CLIENT_ID'
ENV['DIGITAL_OCEAN_CLIENT_SECRET'] = 'DIGITAL_OCEAN_CLIENT_SECRET'
ENV['DIGITAL_OCEAN_USER_EMAIL'] = 'DIGITAL_OCEAN_USER_EMAIL'
ENV['DIGITAL_OCEAN_RECIPIENT_EMAIL'] = 'DIGITAL_OCEAN_RECIPIENT_EMAIL'
ENV['DO_TABLE'] = 'DO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Notify::DoBillAlertEmail do
  before do
    params = {
      refresh_token: ENV.fetch('DIGITAL_OCEAN_REFRESH_TOKEN'),
      client_id: ENV.fetch('DIGITAL_OCEAN_CLIENT_ID'),
      client_secret: ENV.fetch('DIGITAL_OCEAN_CLIENT_SECRET'),
      user_email: ENV.fetch('DIGITAL_OCEAN_USER_EMAIL'),
      recipient_email: ENV.fetch('DIGITAL_OCEAN_RECIPIENT_EMAIL'),
      table_name: ENV.fetch('DO_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Notify::DoBillAlertEmail.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::NotifyDoBillAlertEmail)

      allow(Bot::NotifyDoBillAlertEmail).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
