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
  #   Implementation::FetchGithubIssues.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchGithubIssues < Bas::Bot::Base
    BASE_URL = 'https://api.github.com/search/issues'

    def process
      current_period, previous_period = build_periods

      closed_issues = fetch_closed_issues(current_period)
      opened_issues = fetch_opened_issues(current_period)
      previous_open_issues = fetch_previous_open_issues(previous_period)

      result = normalize_metrics(current_period, closed_issues, opened_issues, previous_open_issues)

      { success: result }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    # Builds the periods for the current and previous months
    def build_periods
      today = Date.today
      current_start = Date.new(today.year, today.month, 1)
      current_end = current_start.next_month.prev_day

      previous_start = current_start << 1
      previous_end = current_start - 1

      [
        { start_date: current_start, end_date: current_end },
        { start_date: previous_start, end_date: previous_end }
      ]
    end

    # Fetches the issues from GitHub
    def fetch_closed_issues(period)
      fetch_count(query_closed_issues(period))
    end

    def fetch_opened_issues(period)
      fetch_count(query_opened_issues(period))
    end

    # Fetches the number of previously opened issues
    def fetch_previous_open_issues(previous_period)
      created_before = fetch_count(query_created_before(previous_period[:end_date]))
      closed_before = fetch_count(query_closed_before(previous_period[:end_date]))
      created_before - closed_before
    end

    # Normalizes the metrics for the return
    def normalize_metrics(period, closed_issues, 
                          opened_issues, previous_open_issues)
      {
        month: period[:start_date].strftime('%B'),
        year: period[:start_date].year,
        closed_issues: {
          name: '# Closed Tickets',
          value: closed_issues
        },
        opened_issues: {
          name: '# Opened Issues',
          value: opened_issues
        },
        previous_open_issues: {
          name: 'Previous Open Issues',
          value: previous_open_issues
        }
      }
    end

    # Fetches the count of issues from GitHub
    def fetch_count(query)
      response = HTTParty.get(BASE_URL, headers: headers, query: { q: query })
      return 0 unless response.code == 200

      data = response.parsed_response
      return 0 if data['incomplete_results']

      data['total_count']
    end

    # Sets the headers for the GitHub API request
    def headers
      {
        'User-Agent' => 'RubyBot',
        'Authorization' => "Bearer #{ENV['GITHUB_TOKEN']}",
        'Accept' => 'application/vnd.github+json'
      }
    end

    # Builds the query for closed issues
    def query_closed_issues(period)
      "org:kommitters is:issue is:closed closed:#{period[:start_date]}..#{period[:end_date]} is:public"
    end

    # Builds the query for opened issues
    def query_opened_issues(period)
      "org:kommitters is:issue is:public created:#{period[:start_date]}..#{period[:end_date]}"
    end

    # Builds the query for issues created before a specific date
    def query_created_before(date)
      "org:kommitters is:issue is:public created:<#{date}"
    end

    # Builds the query for closed issues before a specific date
    def query_closed_before(date)
      "org:kommitters is:issue is:public is:closed closed:<#{date}"
    end
  end
end
