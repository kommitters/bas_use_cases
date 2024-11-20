# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_birthday'

ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'

RSpec.describe Implementation::FormatBirthdays do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:read_data) { { 'birthdays' => [{ 'name' => 'John Doe', 'birthday_date' => '2024-11-15' }] } }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data)
    )
    allow(mocked_shared_storage).to receive(:write).and_return(
      { 'status' => 'success', 'id' => 1 }
    )

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    options = {
      template: 'The Birthday of <name> is today! (<birthday_date>) :birthday: :gift:'
    }

    @bot = Implementation::FormatBirthdays.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FormatBirthdays)

      allow(Implementation::FormatBirthdays).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return(
        { success: { notification: 'The Birthday of John Doe is today! (2024-11-15) :birthday: :gift:' } }
      )
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
