# frozen_string_literal: true

require 'httparty'
require 'uri'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FetchScoresFromGithub class serves as a bot implementation to read repositories
  # from a PostgresDB table, get the score from Github API and write them on a PostgresDB table.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "repos_score",
  #     tag: "FetchRepositoriesFromNotion"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "repos_score",
  #     tag: "FetchScoresFromGithub"
  #   }
  #
  #   options = {
  #     api_url: "https://api.securityscorecards.dev/projects/github.com/kommitters"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FetchScoresFromGithub.new(options, shared_storage).execute
  #
  class FetchScoresFromGithub < Bas::Bot::Base
    # Process function to execute the Notion utility to fetch scores from a GitHub API
    #
    def process
      return { success: { scores: '' } } if unprocessable_response

      repos_list = read_response.data['repos'] || []
      responses = fetch_scores(repos_list)
      normalized = normalize_response(responses)

      { success: { scores: normalized } }
    end

    private

    def fetch_scores(repos_list)
      repos_data = get_repo_info(repos_list)
      repos_data.map do |info|
        url = "#{process_options[:api_url]}/#{info[:name]}"
        response = HTTParty.get(url)

        {
          page_id: info[:page_id],
          name: info[:name],
          response: response
        }
      end
    end

    def get_repo_info(repos_list)
      repos_list.map do |repo_info|
        {
          name: URI(repo_info['repo']).path.split('/').last,
          page_id: repo_info['page_id']
        }
      end
    end

    def normalize_response(responses)
      responses.map do |entry|
        response = entry[:response]
        next unless response.success?

        body = response.parsed_response

        {
          page_id: entry[:page_id],
          name: entry[:name],
          score: body['score']
        }
      end.compact
    end
  end
end
