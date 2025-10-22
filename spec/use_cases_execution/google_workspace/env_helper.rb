# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV.update(
  'DB_HOST' => '127.0.0.1',
  'DB_PORT' => '5432',
  'POSTGRES_DB' => 'test_db',
  'POSTGRES_USER' => 'test_user',
  'POSTGRES_PASSWORD' => 'test_pass',
  'DB_HOST_WAREHOUSE' => '127.0.0.1',
  'DB_PORT_WAREHOUSE' => '5432',
  'WAREHOUSE_POSTGRES_DB' => 'warehouse_test_db',
  'POSTGRES_USER_WAREHOUSE' => 'test_user',
  'POSTGRES_PASSWORD_WAREHOUSE' => 'test_pass',
  'NOTION_SECRET' => 'notion-secret',
  'PROJECTS_NOTION_DATABASE_ID' => 'proj_db_id',
  'ACTIVITIES_NOTION_DATABASE_ID' => 'act_db_id',
  'WORK_ITEMS_NOTION_DATABASE_ID' => 'work_db_id',
  'DOMAINS_NOTION_DATABASE_ID' => 'dom_db_id',
  'DOCUMENTS_NOTION_DATABASE_ID' => 'doc_db_id',
  'WEEKLY_SCOPES_NOTION_DATABASE_ID' => 'weekly_db_id',
  'PERSONS_NOTION_DATABASE_ID' => 'person_db_id',
  'KEY_RESULTS_NOTION_DATABASE_ID' => 'keyres_db',
  'HIRED_PERSONS_NOTION_DATABASE_ID' => 'hired_db_id',
  'WORK_LOGS_URL' => 'http://example.com/worklogs',
  'WORK_LOGS_API_SECRET' => 'log-secret',
  'KOMMITERS_GITHUB_APP_ID' => '1',
  'KOMMIT_CO_GITHUB_APP_ID' => '2',
  'KPIS_NOTION_DATABASE_ID' => 'kpi_db_id',
  'OPERATON_API_BASE_URI' => 'https://operaton.test',
  'OPERATON_USER_ID' => 'test-user',
  'OPERATON_PASSWORD_SECRET' => 'test-secret'
)

require 'rspec'
require 'rack/test'
require 'json'
require 'sinatra/base'

require_relative '../../../src/use_cases_execution/warehouse/config'

# 4. Mock file reads to avoid dependency on physical .pem files.
RSpec.configure do |config|
  config.before(:each) do
    allow(File).to receive(:read).and_call_original

    allow(File).to receive(:read).with('./kommiters_private_key.pem').and_return('fake-pem-key-1')
    allow(File).to receive(:read).with('./kommit_co_private_key.pem').and_return('fake-pem-key-2')
  end
end
