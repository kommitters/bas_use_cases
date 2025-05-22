# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/notify_worklog_in_discord_dm'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/types/read'
require 'time'
require 'discordrb'
require 'logger'

ENV['WORKLOG_DISCORD_TOKEN'] = 'MOCK_DISCORD_BOT_TOKEN'
ENV['WORKLOG_DISCORD_USER_ID'] = '123456789012345678'
ENV['WORKLOG_TABLE'] = 'WORKLOG_TABLE'

RSpec.describe Implementation::NotifyWorklogInDiscordDm do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  let(:read_data_with_notification) do
    { 'notification' => "Here's your daily worklog summary:\n- 2h: Coding\n- 3h: Meeting" }
  end

  let(:read_data_empty_notification) do
    { 'notification' => '' }
  end

  let(:options) do
    {
      token: ENV.fetch('WORKLOG_DISCORD_TOKEN'),
      discord_user_id: ENV.fetch('WORKLOG_DISCORD_USER_ID')
    }
  end

  let(:read_options) do
    {
      connection: 'mock_connection',
      db_table: ENV.fetch('WORKLOG_TABLE'),
      tag: 'FormatWorklogs'
    }
  end

  let(:write_options) do
    {
      connection: 'mock_connection',
      db_table: ENV.fetch('WORKLOG_TABLE'),
      tag: 'NotifyWorklogInDiscordDm'
    }
  end

  let(:mock_discord_bot) { instance_double(Discordrb::Bot) }
  let(:mock_discord_user) { instance_double(Discordrb::User) }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data_with_notification, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)

    allow(Discordrb::Bot).to receive(:new).and_return(mock_discord_bot)
    allow(mock_discord_bot).to receive(:user).and_return(mock_discord_user)
    allow(mock_discord_user).to receive(:dm).and_return(true)

    @bot = Implementation::NotifyWorklogInDiscordDm.new(options, mocked_shared_storage)

    allow(@bot).to receive(:read_response).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data_with_notification, inserted_at: Time.now)
    )

    allow_any_instance_of(Logger).to receive(:info)
  end

  context '.process' do
    it 'sends a DM with the worklog notification' do
      expect(Discordrb::Bot).to receive(:new).with(token: options[:token]).and_return(mock_discord_bot)
      expect(mock_discord_bot).to receive(:user).with(options[:discord_user_id]).and_return(mock_discord_user)
      expect(mock_discord_user).to receive(:dm).with(read_data_with_notification['notification'])

      result = @bot.process
      expect(result).to have_key(:success)
      expect(result[:success][:message]).to eq('DM sent successfully')
    end

    it 'returns an empty success hash if unprocessable_response is true' do
      allow(@bot).to receive(:unprocessable_response).and_return(true)
      result = @bot.process
      expect(result).to have_key(:success)
      expect(result[:success]).to eq({})
    end

    it 'returns an error if Discord token is missing' do
      invalid_options = options.merge(token: nil)
      bot_with_invalid_options = Implementation::NotifyWorklogInDiscordDm.new(invalid_options, mocked_shared_storage)
      allow(bot_with_invalid_options).to receive(:read_response).and_return(
        instance_double(Bas::SharedStorage::Types::Read, data: read_data_with_notification, inserted_at: Time.now)
      )

      result = bot_with_invalid_options.process
      expect(result).to have_key(:error)
      expect(result[:error][:message]).to include('Discord token is missing')
    end

    it 'returns an error if Discord user ID is missing' do
      invalid_options = options.merge(discord_user_id: '')
      bot_with_invalid_options = Implementation::NotifyWorklogInDiscordDm.new(invalid_options, mocked_shared_storage)
      allow(bot_with_invalid_options).to receive(:read_response).and_return(
        instance_double(Bas::SharedStorage::Types::Read, data: read_data_with_notification, inserted_at: Time.now)
      )

      result = bot_with_invalid_options.process
      expect(result).to have_key(:error)
      expect(result[:error][:message]).to include('Discord user ID is missing')
    end

    it 'handles errors during DM sending' do
      allow(mock_discord_user).to receive(:dm).and_raise(StandardError, 'Discord API error')

      result = @bot.process
      expect(result).to have_key(:error)
      expect(result[:error][:message]).to include('Discord API error')
    end
  end
end
