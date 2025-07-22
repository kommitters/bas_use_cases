# frozen_string_literal: true

require 'rspec'
require 'date'
require_relative '../../../src/implementations/fetch_pto_from_google.rb'

RSpec.describe Implementation::FetchPtoFromGoogle do
  let(:today) { Date.today }

  let(:ptos) do
    [
      # [ ]Covers today (yesterday to tomorrow)
      { 'Person' => 'Jane Doe', 'StartdateTime' => (today - 1).to_s, 'EndDateTime' => (today + 1).to_s },

      # [x] Future only
      { 'Person' => 'John Smith', 'StartdateTime' => (today + 7).to_s, 'EndDateTime' => (today + 8).to_s },

      # [x] Past only
      { 'Person' => 'Alice', 'StartdateTime' => (today - 7).to_s, 'EndDateTime' => (today - 1).to_s },

      # [ ] Today only
      { 'Person' => 'Bob', 'StartdateTime' => today.to_s, 'EndDateTime' => today.to_s },

      # [ ] Starts today, ends in 3 days
      { 'Person' => 'Charlie', 'StartdateTime' => today.to_s, 'EndDateTime' => (today + 3).to_s },

      # [ ] Started 3 days ago, ends today
      { 'Person' => 'Diana', 'StartdateTime' => (today - 3).to_s, 'EndDateTime' => today.to_s },

      # [x] Only tomorrow
      { 'Person' => 'Eve', 'StartdateTime' => (today + 1).to_s, 'EndDateTime' => (today + 1).to_s },

      # [ ] Long PTO (10 days ago to 10 days ahead)
      { 'Person' => 'Frank', 'StartdateTime' => (today - 10).to_s, 'EndDateTime' => (today + 10).to_s },

      # [x] One-day PTO in the past (yesterday)
      { 'Person' => 'Grace', 'StartdateTime' => (today - 1).to_s, 'EndDateTime' => (today - 1).to_s },

      # [x] One-day PTO in the future (tomorrow)
      { 'Person' => 'Hank', 'StartdateTime' => (today + 1).to_s, 'EndDateTime' => (today + 1).to_s }
    ]
  end

  let(:options) { { ptos: ptos } }
  let(:reader) { double('SharedStorageReader') }
  let(:writer) { double('SharedStorageWriter') }

  subject { described_class.new(options, reader, writer) }

  describe '#process' do
    let(:result) { subject.process }
    let(:ptos_result) { result[:success][:ptos] }

    # People whose PTOs should include today
    let(:expected_people) do
      ['Jane Doe', 'Bob', 'Charlie', 'Diana', 'Frank']
    end

    # People whose PTOs should not be included
    let(:unexpected_people) do
      ['John Smith', 'Alice', 'Eve', 'Grace', 'Hank']
    end

    it 'includes only people who are on PTO today' do
      expected_people.each do |name|
        found = ptos_result.any? { |msg| msg.include?(name) }
        unless found
          puts "\n Expected '#{name}' to be included but wasn't.\nAll messages: #{ptos_result.inspect}"
        end
        expect(found).to be true
      end
    end

    it 'excludes people not on PTO today' do
      unexpected_people.each do |name|
        found = ptos_result.any? { |msg| msg.include?(name) }
        if found
          puts "\n Expected '#{name}' to be excluded but was found.\nAll messages: #{ptos_result.inspect}"
        end
        expect(found).to be false
      end
    end

    it 'formats the messages correctly' do
      ptos_result.each do |msg|
        expect(msg).to match(/will not be working between/)
        expect(msg).to match(/And returns the/)
      end
    end
  end
end
