# frozen_string_literal: true

require 'rspec'
require 'json'
require 'httparty'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/fetch_scores_from_github'

RSpec.describe Implementation::FetchScoresFromGithub do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  let(:read_data) do
    {
      'repos' => [
        {
          'name' => 'Example Repo',
          'repo' => 'https://github.com/kommitters/example-repo',
          'page_id' => 'abcd-1234'
        }
      ]
    }
  end

  let(:mocked_http_response) do
    instance_double(HTTParty::Response, success?: true, parsed_response: { 'score' => 8.9 },
                                        body: { score: 8.9 }.to_json)
  end

  let(:options) do
    {
      api_url: 'https://fake.api.scorecards.dev/projects'
    }
  end

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ success: { scores: [{ page_id: 'abcd-1234',
                                                                                       name: 'example-repo',
                                                                                       score: 8.9 }] } })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    allow(HTTParty).to receive(:get).and_return(mocked_http_response)

    @bot = Implementation::FetchScoresFromGithub.new(options, mocked_shared_storage)
  end

  it 'reads repositories, gets scores from API and normalizes response' do
    result = @bot.execute

    expect(result).to have_key(:success)
    scores = result[:success][:scores]

    expect(scores).to be_an(Array)
    expect(scores.first).to include(
      page_id: 'abcd-1234',
      name: 'example-repo',
      score: 8.9
    )
  end
end
