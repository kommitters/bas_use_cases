# frozen_string_literal: true

require 'httparty'
require 'date'
require 'bas/bot/base'

module Implementation
  #
  # The Implementation::FetchGithubIssues class serves as a bot implementation to fetch issues from
  # the GitHub API and process them.
  #
  # <br>
  # <b>Example</b>

  #  write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'github_issues',
  #   tag: 'GithubIssueRequest'
  #  }

  #
  #   options = {
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  # Implementation::FetchGithubIssues.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchGithubIssues < Bas::Bot::Base
    BASE_URL = 'https://api.github.com/search/issues'

    def process
      current_period = build_current_period
      previous_period = build_previous_period(current_period)

      closed_issues = fetch_closed_issues(current_period)
      opened_issues = fetch_opened_issues(current_period)
      previous_open_issues = fetch_previous_open_issues(previous_period)

      result = normalize_metrics(current_period, closed_issues, opened_issues, previous_open_issues)

      { success: result }
    rescue StandardError => e
      warn "[ERROR] Exception in process: #{e.message}"
      { error: { message: e.message } }
    end

    private

    def build_current_period
      today = Date.today
      start_date = Date.new(today.year, today.month, 1)
      end_date = (start_date >> 1) - 1

      { start_date:, end_date: }
    end

    def build_previous_period(current_period)
      previous_end = current_period[:start_date] - 1
      previous_start = Date.new(previous_end.year, previous_end.month, 1)

      { start_date: previous_start, end_date: previous_end }
    end

    def fetch_closed_issues(period)
      fetch_count(query_closed_issues(period))
    end

    def fetch_opened_issues(period)
      fetch_count(query_opened_issues(period))
    end

    ##
    # Calculates open issues at the end of the *previous* month
    def fetch_previous_open_issues(previous_period)
      boundary_date = previous_period[:end_date]
      created_before = fetch_count("org:kommitters is:issue is:public created:<#{boundary_date}")
      closed_before  = fetch_count("org:kommitters is:issue is:public is:closed closed:<#{boundary_date}")
      created_before - closed_before
    end

    def normalize_metrics(period, closed_issues, opened_issues, previous_open_issues)
      {
        month: period[:start_date].strftime('%B'),
        year: period[:start_date].year,
        closed_issues: build_metric('# Closed Tickets', closed_issues.to_i),
        opened_issues: build_metric('# Opened Issues', opened_issues.to_i),
        previous_open_issues: build_metric('Previous Open Issues', previous_open_issues.to_i)
      }
    end

    def build_metric(name, value)
      { name:, value: }
    end

    def query_closed_issues(period)
      "org:kommitters is:issue is:closed closed:#{period[:start_date]}..#{period[:end_date]} is:public"
    end

    def query_opened_issues(period)
      "org:kommitters is:issue is:public created:#{period[:start_date]}..#{period[:end_date]}"
    end

    def fetch_count(query)
      response = HTTParty.get(BASE_URL, headers: headers, query: { q: query })

      unless response.code == 200
        warn "[GitHub API] Error #{response.code} for query: #{query}"
        return 0
      end

      data = response.parsed_response
      data['total_count'] || 0
    end

    def headers
      {
        'User-Agent' => 'RubyBot',
        'Accept' => 'application/vnd.github+json'
      }
    end
  end
end
