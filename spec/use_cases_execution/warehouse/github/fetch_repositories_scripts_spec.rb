# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'

require_relative '../../../../src/implementations/fetch_repositories_from_github'

CONFIG_PATH = File.expand_path('../../../../src/use_cases_execution/warehouse/config.rb', __dir__)
require CONFIG_PATH

RSpec.shared_examples 'repositories runner script' do |script_path:, github_method:|
  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:impl_double) { instance_double(Implementation::FetchRepositoriesFromGithub) }
  let(:stub_config) do
    { private_pem: 'pem', app_id: 'app', organization: 'org' }
  end

  before do
    allow(Config::Github).to receive(github_method).and_return(stub_config)
  end

  it 'initializes shared storage and executes the implementation' do
    expect(Bas::SharedStorage::Postgres).to receive(:new) do |args|
      expect(args).to be_a(Hash)
      expect(args).to have_key(:read_options)
      expect(args).to have_key(:write_options)
      expect(args[:read_options][:db_table]).to eq('warehouse_sync')
      expect(args[:write_options][:db_table]).to eq('warehouse_sync')
      expect(args[:write_options][:tag]).to eq('FetchRepositoriesFromGithub')
      shared_storage
    end

    expect(Implementation::FetchRepositoriesFromGithub)
      .to receive(:new).with(stub_config, shared_storage).and_return(impl_double)
    expect(impl_double).to receive(:execute)

    expect { load script_path }.not_to raise_error
  end
end

KOMMIT_CO_SCRIPT = File.expand_path(
  '../../../../src/use_cases_execution/warehouse/github/fetch_kommit_co_repositories_from_github.rb', __dir__
)
KOMMITTERS_SCRIPT = File.expand_path(
  '../../../../src/use_cases_execution/warehouse/github/fetch_kommitters_repositories_from_github.rb', __dir__
)

RSpec.describe 'Fetch repositories runner scripts' do
  include_examples 'repositories runner script',
                   script_path: KOMMIT_CO_SCRIPT,
                   github_method: :kommit_co

  include_examples 'repositories runner script',
                   script_path: KOMMITTERS_SCRIPT,
                   github_method: :kommiters
end
