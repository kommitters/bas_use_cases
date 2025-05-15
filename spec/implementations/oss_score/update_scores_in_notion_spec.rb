# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/utils/notion/update_db_page'
require_relative '../../../src/implementations/update_scores_in_notion'

RSpec.describe Implementation::UpdateScoresInNotion do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_notion_updater) { instance_double(Utils::Notion::UpdateDatabasePage) }

  let(:read_data) do
    {
      'scores' => [
        { 'page_id' => 'abcd-1234', 'score' => 8.5 },
        { 'page_id' => nil, 'score' => 7.3 }, 
        { 'page_id' => 'wxyz-5678', 'score' => nil }
      ]
    }
  end

  let(:options) do
    { secret: 'fake_notion_secret' }
  end

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data)
    )

    allow(mocked_shared_storage).to receive(:write).and_return({ success: { updated: 1 } })
    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)

    allow(Utils::Notion::UpdateDatabasePage).to receive(:new)
      .with(hash_including(page_id: 'abcd-1234', secret: 'fake_notion_secret'))
      .and_return(mocked_notion_updater)

    allow(mocked_notion_updater).to receive(:execute)
      .and_return(instance_double(Net::HTTPSuccess, code: 200))

    @bot = Implementation::UpdateScoresInNotion.new(options, mocked_shared_storage)
  end

  it 'Updates valid pages in Notion and counts correctly' do
    result = @bot.execute

    expect(result).to eq({ success: { updated: 1 } })
  end
end
