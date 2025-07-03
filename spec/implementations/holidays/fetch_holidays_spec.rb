# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_holidays'

RSpec.describe Implementation::FetchHolidays do
  context '.process' do
    it 'should return a list of holidays' do
      options = {
        country: 'US',
        year: 2024,
        month: 1,
        day: 1
      }

      mock_holidays_request = instance_double(Utils::Holidays::Request)
      allow(Utils::Holidays::Request).to receive(:new).with(
        country: options[:country],
        year: options[:year],
        month: options[:month],
        day: options[:day]
      ).and_return(mock_holidays_request)
      allow(mock_holidays_request).to receive(:execute).and_return({ 'holidays' => ['New Year'] })

      bot = described_class.new(options, nil, nil)
      result = bot.process

      expect(result).to eq({ success: { holidays: ['New Year'] } })
    end

    it 'should return an error if the request fails' do
      options = {
        country: 'US',
        year: 2024,
        month: 1,
        day: 1
      }

      mock_holidays_request = instance_double(Utils::Holidays::Request)
      allow(Utils::Holidays::Request).to receive(:new).with(
        country: options[:country],
        year: options[:year],
        month: options[:month],
        day: options[:day]
      ).and_return(mock_holidays_request)
      allow(mock_holidays_request).to receive(:execute).and_return({ error: 'Failed to fetch holidays' })

      bot = described_class.new(options, nil, nil)
      result = bot.process

      expect(result).to eq({ error: { message: 'Failed to fetch holidays' } })
    end
  end
end
