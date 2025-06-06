# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_github_issues_for_notion'

RSpec.describe Implementation::FormatGithubIssuesForNotion do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:read_data) do
    [
      {
        'title' => 'Example GitHub Issue',
        'number' => 123,
        'html_url' => 'https://github.com/owner/repo/issues/123',
        'body' => 'This is an example issue body with some description.',
        'labels' => [
          { 'name' => 'bug' },
          { 'name' => 'enhancement' }
        ]
      }
    ]
  end

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

    options = {}

    @bot = Implementation::FormatGithubIssuesForNotion.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FormatGithubIssuesForNotion)

      allow(Implementation::FormatGithubIssuesForNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return(
        {
          success: [
            {
              'Detail' => {
                type: 'title',
                title: [
                  {
                    type: 'text',
                    text: { content: 'Example GitHub Issue' }
                  }
                ]
              },
              'Tags' => {
                multi_select: [
                  { name: 'bug' },
                  { name: 'enhancement' }
                ]
              },
              'Github issue id' => {
                rich_text: [
                  {
                    type: 'text',
                    text: { content: '123' }
                  }
                ]
              },
              'children' => [
                {
                  object: 'block',
                  type: 'file',
                  file: {
                    type: 'external',
                    external: { url: 'https://github.com/owner/repo/issues/123' },
                    name: 'Check issue #123 on Github'
                  }
                },
                {
                  type: 'heading_1',
                  heading_1: {
                    rich_text: [{
                      type: 'text',
                      text: { content: 'Issue description' }
                    }]
                  }
                },
                {
                  object: 'block',
                  type: 'paragraph',
                  paragraph: {
                    rich_text: [
                      { type: 'text', text: { content: 'This is an example issue body with some description.' } }
                    ]
                  }
                }
              ]
            }
          ]
        }
      )
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
