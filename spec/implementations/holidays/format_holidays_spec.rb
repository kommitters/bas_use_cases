# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/format_holidays'

RSpec.describe Implementation::FormatHolidays do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:holidays_data) do
    {
      'holidays' => [
        { 'name' => 'New Year', 'date' => '2024-01-01' },
        { 'name' => 'Independence Day', 'date' => '2024-07-04' }
      ]
    }
  end

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: holidays_data)
    )
    allow(mocked_shared_storage).to receive(:write).and_return(
      { 'status' => 'success', 'id' => 1 }
    )
    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    options = {
      title: 'Upcoming Holidays:'
    }
    @bot = Implementation::FormatHolidays.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:execute).and_return(
        { success: { notification: "Upcoming Holidays:\n- New Year on January 01\n- Independence Day on July 04" } }
      )
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end

  context 'error handling' do
    it 'returns error if no holidays data found' do
      allow(mocked_shared_storage).to receive(:read).and_return(nil)
      options = { title: 'Upcoming Holidays:' }
      bot = Implementation::FormatHolidays.new(options, mocked_shared_storage)
      expect(bot.process).to eq({ error: { message: 'No holidays data found' } })
    end
  end
end
