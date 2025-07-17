# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/prepare_billing_start_instance'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

RSpec.describe Implementation::PrepareBillingStartInstance do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  
  let(:contracts) do
    [
      {
        "contract_id": "C001",
        "client_id": "CL001",
        "client_name": "Client A",
        "start_date": "2025-01-01",
        "last_billed_date": "2025-06-20",
        "billing_frequency": "monthly",
        "active": true,
        "fixed_price": 1000,
        "fixed_rate": nil,
        "rate_unit": nil,
        "terms": {
          "payment_due_days": 30,
          "grace_period_days": 5
        }
      },
      {
        "contract_id": "C002",
        "client_id": "CL002",
        "client_name": "Client B",
        "start_date": "2025-01-15",
        "last_billed_date": "2025-07-10",
        "billing_frequency": "weekly",
        "active": true,
        "fixed_price": nil,
        "fixed_rate": 50,
        "rate_unit": "hourly",
        "terms": {
          "payment_due_days": 15,
          "grace_period_days": 3
        }
      },
      {
        "contract_id": "C003",
        "client_id": "CL003",
        "client_name": "Client C",
        "start_date": "2025-02-01",
        "last_billed_date": "2025-06-30",
        "billing_frequency": "monthly",
        "active": false,
        "fixed_price": 2000,
        "fixed_rate": nil,
        "rate_unit": nil,
        "terms": {
          "payment_due_days": 30,
          "grace_period_days": 5
        }
      }
    ]
  end

  let(:options) do
    {
      operaton_base_url: 'http://example.com',
      process_key: 'billing_process',
      operaton_api_user: 'user',
      operaton_password: 'password'
    }
  end

  let(:reader) { Bas::SharedStorage::Default.new }
  let(:writer) { double('Bas::SharedStorage::Postgres') }
  let(:client) { double('Utils::Operaton::ProcessClient') }

  subject { described_class.new(options, reader, writer) }

  before do
    allow(subject).to receive(:read_contracts_from_json).and_return(contracts)
    allow(Utils::Operaton::ProcessClient).to receive(:new).and_return(client)
    allow(writer).to receive(:write)
  end

  describe '#process' do
    context 'when there are contracts to bill' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2025, 7, 20))
        allow(client).to receive(:instance_with_business_key_exists?).and_return(false)
      end

      it 'returns the contracts that are due for billing' do
        result = subject.process
        expect(result[:success][:contracts].map { |c| c[:contract_id] }).to eq(["C001", "C002"])
      end
    end

    context 'when no contracts are due for billing' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2025, 7, 16))
      end

      it 'returns an empty array' do
        result = subject.process
        expect(result[:success][:contracts]).to be_empty
      end
    end

    context 'when all due contracts already have an instance' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2025, 7, 20))
        allow(client).to receive(:instance_with_business_key_exists?).and_return(true)
      end

      it 'returns an empty array' do
        result = subject.process
        expect(result[:success][:contracts]).to be_empty
      end
    end
  end

  describe '#write' do
    let(:processed_contracts) do
      contracts.select { |c| c['active'] }
    end

    before do
      subject.instance_variable_set(:@process_response, { success: { contracts: processed_contracts } })
    end

    it 'writes each contract to the shared storage' do
      processed_contracts.each do |contract|
        expect(writer).to receive(:write).with(hash_including(success: hash_including(business_key: contract[:contract_id])))
      end
      subject.write
    end
  end
end