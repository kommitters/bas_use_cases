# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_wip_limit_exceeded'

ENV['WIP_TABLE'] = 'WIP_TABLE'

RSpec.describe Implementation::FormatWipLimitExceeded do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: {
                        'exceeded_domain_count' => [
                          { 'domain' => 'domain1', 'exceeded' => 5 },
                          { 'domain' => 'domain2', 'exceeded' => 3 }
                        ]
                      }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage).to receive(:read_response).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }.to_json, inserted_at: Time.now)
    )

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    options = {
      template: ':warning: The <domain> WIP limit was exceeded by <exceeded>'
    }

    @bot = Implementation::FormatWipLimitExceeded.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FormatWipLimitExceeded)

      allow(Implementation::FormatWipLimitExceeded).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bot and format the notification' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
