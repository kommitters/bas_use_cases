# frozen_string_literal: true

require 'httparty'
require 'date'
require 'bas/bot/base'

module Implementation
##
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
      current_period = current_month_range
      previous_period = previous_month_range

      # Fetch the number of closed and opened issues for the current month
      closed_issues = fetch_count(query_closed_issues(current_period))

      # Fetch the number of opened issues for the current month
      opened_issues = fetch_count(query_opened_issues(current_period))

      # Fetch the number of created and closed issues for the previous month
      created_before = fetch_count(query_created_before(previous_period[:end_date]))

      # Fetch the number of closed issues for the previous month
      closed_before = fetch_count(query_closed_before(previous_period[:end_date]))

      # Calculate the number of previous open issues
      previous_open_issues = created_before - closed_before

      # Normalize the data for the response
      result = normalize({
        year: current_period[:start_date].year,
        month: current_period[:start_date].strftime('%B'),
        closed_issues:,
        opened_issues:,
        previous_open_issues:
      })
      
      { success: result }

    rescue StandardError => e
      { error: { message: e.message } }

    end

    private

    # Define the date range for the current and previous month
    def current_month_range
      today = Date.today
      start_date = Date.new(today.year, today.month, 1)
      end_date = start_date.next_month.prev_day
      { start_date:, end_date: }
    end

    # Define the date range for the previous month
    def previous_month_range
      today = Date.today
      start_date = Date.new(today.year, today.month, 1) << 1
      end_date = start_date.next_month.prev_day
      { start_date:, end_date: }
    end

    # Fetch the count of issues based on the provided query
    def fetch_count(query)
      response = HTTParty.get(
        BASE_URL,
        headers: headers,
        query: { q: query }
      )

      return 0 unless response.code == 200
      data = response.parsed_response
      return 0 if data['incomplete_results']

      data['total_count']
    end

    # Define the headers for the GitHub API request
    def headers
      {
        'User-Agent' => 'RubyBot',
        'Authorization' => "Bearer #{ENV['GITHUB_TOKEN']}",
        'Accept' => 'application/vnd.github+json'
      }
    end

    # Define the queries for fetching issues
    def query_closed_issues(period)
      "org:kommitters is:issue is:closed closed:#{period[:start_date]}..#{period[:end_date]} is:public"
    end

    # Define the query for fetching opened issues
    def query_opened_issues(period)
      "org:kommitters is:issue is:public created:#{period[:start_date]}..#{period[:end_date]}"
    end

    # Define the query for fetching issues created before a specific date
    def query_created_before(date)
      "org:kommitters is:issue is:public created:<#{date}"
    end

    # Define the query for fetching closed issues before a specific date
    def query_closed_before(date)
      "org:kommitters is:issue is:public is:closed closed:<#{date}"
    end

    # Normalize the data for the response
    def normalize(data)
      {
        month: data[:month],
        year: data[:year],
        closed_issues: {
          name: '# Closed Tickets',
          value: data[:closed_issues]
        },
        opened_issues: {
          name: '# Opened Issues',
          value: data[:opened_issues]
        },
        previous_open_issues: {
          name: 'Previous Open Issues',
          value: data[:previous_open_issues]
        }
      }
    end
  end
end
