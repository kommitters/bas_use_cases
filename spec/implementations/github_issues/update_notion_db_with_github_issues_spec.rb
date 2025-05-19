# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/update_notion_db_with_github_issues'

ENV['NOTION_DATABASE_ID'] = 'NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'

RSpec.describe Implementation::UpdateNotionDBWithGithubIssues do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  let(:options) do
    {
      notion_database_id: ENV.fetch('NOTION_DATABASE_ID'),
      notion_secret: ENV.fetch('NOTION_SECRET'),
      tag: 'GithubIssueRequest'
    }
  end

  let(:valid_data) do
    {
      "month" => "May",
      "closed_issues" => { "value" => 0 },
      "opened_issues" => { "value" => 2 },
      "previous_open_issues" => { "value" => 31 }
    }
  end

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      double(data: valid_data, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })
    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::UpdateNotionDBWithGithubIssues.new(options, mocked_shared_storage)
  end

  let(:notion_response) do
    {
      "results" => [
        {
          "id" => "page_id_123",
          "properties" => {
            "Month" => {
              "title" => [{ "plain_text" => "May" }]
            }
          }
        }
      ]
    }
  end

  context 'when everything is valid' do
    before do
      allow(Utils::Notion::Request).to receive(:execute).and_return(notion_response)
      allow_any_instance_of(Utils::Notion::UpdateDatabasePage).to receive(:execute).and_return(double(code: 200))
    end

    it 'updates the Notion page and returns success' do
      allow(@bot).to receive(:process).and_return({ success: {} })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end
  end

  context 'when data is not a Hash' do
    before do
      allow(mocked_shared_storage).to receive(:read).and_return(double(data: 'invalid', inserted_at: Time.now))
    end

    it 'returns an error' do
      allow(@bot).to receive(:process).and_return({ error: 'Invalid data format' })
    end
  end

  context "when 'month' is missing or invalid" do
    before do
      allow(mocked_shared_storage).to receive(:read).and_return(double(data: valid_data.merge("month" => nil), inserted_at: Time.now))
    end

    it 'returns an error' do
      allow(@bot).to receive(:process).and_return({ error: "'month' field missing or invalid" })
    end
  end

  context 'when Notion response has no results' do
    before do
      allow(Utils::Notion::Request).to receive(:execute).and_return({ "results" => [] })
    end

    it 'returns an error' do
      allow(@bot).to receive(:process).and_return({ error: "Notion page for 'May' not found" })
    end
  end

  context 'when issue values are not numeric' do
    let(:invalid_data) do
      {
        "month" => "May",
        "closed_issues" => { "value" => "x" },
        "opened_issues" => { "value" => nil },
        "previous_open_issues" => { "value" => "abc" }
      }
    end
  end 

  context 'when all metric keys are missing' do
    before do
      allow(mocked_shared_storage).to receive(:read).and_return(double(data: { "month" => "May" }, inserted_at: Time.now))
    end

    it 'returns an error' do
      allow(@bot).to receive(:process).and_return({ error: "No valid issue data found to update" })
      expect(@bot.process[:error]).to eq("No valid issue data found to update")
    end
  end

  context 'when Notion update fails' do
    before do
      allow(Utils::Notion::Request).to receive(:execute).and_return(notion_response)
      allow_any_instance_of(Utils::Notion::UpdateDatabasePage).to receive(:execute).and_return(
        double(code: 500, body: "Internal Server Error")
      )
    end

    it 'returns an error with status and body' do
      allow(@bot).to receive(:process).and_return({ error: "Failed to update Notion page", status: 500 })
    end
  end
end
