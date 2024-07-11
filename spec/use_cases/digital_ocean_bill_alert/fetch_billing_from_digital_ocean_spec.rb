# frozen_string_literal: true

require 'rspec'
require_relative '../../use_cases/digital_ocean_bill_alert/fetch_billing_from_digital_ocean'

ENV['DIGITAL_OCEAN_SECRET'] = 'DIGITAL_OCEAN_SECRET'
ENV['DO_TABLE'] = 'DO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Fetch::BillingFromDigitalOcean do
  before do
    params = {
      digital_ocean_secret: ENV.fetch('DIGITAL_OCEAN_SECRET'),
      table_name: ENV.fetch('DO_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Fetch::BillingFromDigitalOcean.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchBillingFromDigitalOcean)

      allow(Bot::FetchBillingFromDigitalOcean).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
