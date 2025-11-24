# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'octokit'

require_relative '../../../implementations/fetch_github_issues'
require_relative '../config'

# Configuration
READ_OPTIONS = {
  connection: Config::CONNECTION,
  db_table: 'YOUR_TABLE_NAME_HERE',                 # Query for the most recent issues by tag
  tag: 'YOUR_READ_TAG_HERE',
  where: 'tag=$1 ORDER BY inserted_at DESC',
  params: ['YOUR_READ_TAG_HERE']
}.freeze

WRITE_OPTIONS = {
  connection: Config::CONNECTION,
  db_table: 'YOUR_TABLE_NAME_HERE',
  tag: 'YOUR_WRITE_TAG_HERE'
}.freeze

OPTIONS = {
  private_pem: Config::PRIVATE_PEM,
  app_id: Config::APP_ID,
  repo: 'YOUR_ORG_OR_USER/YOUR_REPOSITORY',         # e.g. "MyOrg/my-repo"
  filters: { state: 'open' },
  organization: 'YOUR_ORG_OR_USER',                 # GitHub organization or username
  domain: Config::DOMAIN,
  status: 'YOUR_INTERNAL_STATUS',                   # e.g. "Backlog"
  work_item_type: Config::WORK_ITEM_TYPE,
  type_id: 'YOUR_TYPE_UUID',                        # e.g. "ecc3b2bcc3c941d29e3499721c063dd6"
  connection: Config::CONNECTION,
  db_table: 'YOUR_TABLE_NAME_HERE',
  tag: 'YOUR_INSERTION_TAG'
}.freeze

module Utils
  module Github
    class OctokitClient
      private

      # Overrides method to get an Installation Access Token
      def access_token
        app = Octokit::Client.new(client_id: @params[:app_id], bearer_token: jwt)
        installation_id = begin
          app.find_organization_installation(@params[:organization]).id
        rescue Octokit::NotFound
          app.find_user_installation(@params[:organization]).id
        end
        app.create_app_installation_access_token(installation_id)[:token]
      end
    end
  end
end

## Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options: READ_OPTIONS, write_options: WRITE_OPTIONS })

  Implementation::FetchGithubIssues.new(OPTIONS, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
