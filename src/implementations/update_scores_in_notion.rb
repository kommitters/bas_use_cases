# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/notion/update_db_page'

module Implementation
  ##
  # The Implementation::UpdateScoresInNotion class serves as a bot implementation to read scores from a
  # PostgresDB table and write them on a Notion Database.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "repos_score",
  #     tag: "FetchScoresFromGithub"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "repos_score",
  #     tag: "UpdateScoresInNotion"
  #   }
  #
  #   options = {
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateScoresInNotion.new(options, shared_storage).execute
  #
  class UpdateScoresInNotion < Bas::Bot::Base
    # Process function to execute the Notion utility to update property score in a Notion Database
    #
    def process
      return { success: { updated: 0 } } if unprocessable_response

      updated_count = 0
      scores = read_response.data['scores'] || []

      scores.each do |entry|
        next unless entry['page_id'] && entry['score']

        result = update_score(entry['page_id'], entry['score'])
        updated_count += 1 if result.code == 200
      end

      { success: { updated: updated_count } }
    end

    private

    def update_score(page_id, score)
      options = {
        page_id: page_id,
        secret: process_options[:secret],
        body: { properties: { 'OSSF Scorecard Score' => { number: score } } }
      }

      Utils::Notion::UpdateDatabasePage.new(options).execute
    end
  end
end
