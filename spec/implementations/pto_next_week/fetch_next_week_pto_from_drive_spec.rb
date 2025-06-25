# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require 'date'
require_relative '../../../src/implementations/fetch_next_week_pto_from_drive'

RSpec.describe Implementation::FetchNextWeekPtosFromGoogleSheets do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }

  before do
    options = {
      spreadsheet_id: 'FAKE_SPREADSHEET_ID',
      credentials_path: 'spec/fixtures/fake_credentials.json'
    }

    allow(File).to receive(:open).with('spec/fixtures/fake_credentials.json').and_return(StringIO.new('{}'))

    fake_credentials = instance_double(Google::Auth::ServiceAccountCredentials)
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(fake_credentials)
    allow(fake_credentials).to receive(:fetch_access_token!).and_return({})

    fake_service = instance_double(Google::Apis::SheetsV4::SheetsService)
    fake_response = instance_double(Google::Apis::SheetsV4::ValueRange, values: [
      ['1', 'Laura', '', '07/01/2025', '07/03/2025', '', '', '🏖️', '', 'active']
    ])

    allow(Google::Apis::SheetsV4::SheetsService).to receive(:new).and_return(fake_service)
    allow(fake_service).to receive(:authorization=)
    allow(fake_service).to receive(:get_spreadsheet_values).and_return(fake_response)

    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage_writer).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::FetchNextWeekPtosFromGoogleSheets.new(options, mocked_shared_storage_reader, mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { ptos: ['Laura will not be working between July 1, 2025 and July 3, 2025 due to 🏖️. And returns the Friday July 4 of 2025.'] } })
      allow(@bot).to receive(:execute).and_call_original
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
