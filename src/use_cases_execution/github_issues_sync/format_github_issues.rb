# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_github_issues_for_apex'
require_relative 'config'

##
# Wrapper class that allows formatting while safely skipping summary rows (`{ created: true }`)
# and avoiding error rows when the queue is empty.
#
class FormatGithubIssuesForApexWithoutSummary < Implementation::FormatGithubIssuesForApex
  def process
    data = read_response.data
    return skip_summary if summary_row?(data)

    super
  end

  def write
    return if skipped_summary? || process_response&.key?(:error)

    super
  end

  private

  def summary_row?(data)
    return false unless data.is_a?(Hash)

    data['created'] == true || data[:created] == true
  end

  def skip_summary
    { success: { skipped: true } }
  end

  def skipped_summary?
    process_response.is_a?(Hash) &&
      process_response[:success].is_a?(Hash) &&
      process_response[:success][:skipped]
  end
end

read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues_apex',
  where: "stage='unprocessed' AND tag=$1 ORDER BY inserted_at DESC",
  params: ['GithubIssueRequest']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues_apex',
  tag: 'FormatGithubIssuesApex'
}

options = {
  close_connection_after_process: false,
  avoid_empty_data: true,
  default_status: Config::DEFAULT_STATUS,
  default_deadline: Config::DEFAULT_DEADLINE
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  (1..Config::MAX_RECORDS).each do
    object = FormatGithubIssuesForApexWithoutSummary.new(options, shared_storage)
    object.execute
    break if object.process_response.key?(:error)
  end

  shared_storage.close_connections
rescue StandardError => e
  shared_storage&.close_connections
  Logger.new($stdout).info(e.message)
end
