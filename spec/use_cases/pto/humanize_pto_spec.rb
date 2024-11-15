# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/humanize_pto'

ENV['OPENAI_SECRET'] = 'OPENAI_SECRET'
ENV['PTO_OPENAI_ASSISTANT'] = 'PTO_OPENAI_ASSISTANT'
ENV['BIRTHDAY_TABLE'] = 'PTO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION ={
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

RSpec.describe Bot::HumanizePto do
  before do
    read_options = {
      connection: CONNECTION,
      db_table: 'pto',
      tag: 'FetchPtosFromNotion'
    }
    
    write_options = {
      connection: CONNECTION,
      db_table: 'pto',
      tag: 'HumanizePto'
    }
    
    options = {
      secret: ENV.fetch('OPENAI_SECRET'),
      assistant_id: ENV.fetch('PTO_OPENAI_ASSISTANT'),
      prompt: "Today is march 1 and the PTO's are: {data}"
    }
    shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

    Bot::HumanizePto.new(options, shared_storage).execute
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::HumanizePto)

      allow(Bot::HumanizePto).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
