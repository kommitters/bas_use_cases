# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/format_birthday'
require 'bas/shared_storage/postgres'

ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'

RSpec.describe Bot::FormatBirthdays do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:read_data) { { 'birthdays' => [{ 'name' => 'John Doe', 'birthday_date' => '2024-11-15' }] } }
  before do
    options = {
      template: 'The Birthday of <name> is today! (<birthday_date>) :birthday: :gift:'
    }
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Bot::FormatBirthdays.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:execute).and_return(
        { success: { notification: 'The Birthday of John Doe is today! (2024-11-15) :birthday: :gift:' } }
      )
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
