# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::FetchNewNetworksFromApollo class serves as a bot implementation to fetch "networks"
  # from apollo.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "FetchNewNetworksFromApollo"
  #   }
  #
  #   options = {
  #     apollo_token: "apollo_token"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FetchNewNetworksFromApollo.new(options, shared_storage).execute
  #
  class FetchNewNetworksFromApollo < Bas::Bot::Base
    URL = 'https://api.apollo.io/api/v1/mixed_people/search'
    BATCH_SIZE = 50

    def process
      response = fetch_networks

      if response.code == 200
        networks = normalize_response(response.parsed_response['people'])

        { success: { networks: } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def fetch_networks
      HTTParty.post(URL, headers:, query:)
    end

    def query
      {
        person_title: ['president', 'ceo', 'founder', 'co-founder', 'coo', 'cso', 'cio', 'vp',
                       'director of operations', 'vp of operations'],
        include_similar_titles: true,
        person_locations: ['USA'],
        person_seniorities: %w[founder vp],
        organization_num_employees_ranges: %w[101-200 201-500],
        per_page: BATCH_SIZE
      }
    end

    def headers
      {
        "Content-Type": 'application/json',
        "x-api-key": process_options[:apollo_token]
      }
    end

    def normalize_response(people)
      people.map do |person|
        {
          status: 'identified', name: person['name'],
          connection_source: 'Contact Research',
          linkedin_url: person['linkedin_url'],
          role: extract_role(person), country: person['country'],
          qualifications: person['qualifications'],
          industry: person.dig('organization', 'organization')
        }
      end
    end

    def extract_role(person)
      role = person['seniority']
      role = person['title'].split(',').first if role.nil? || role.empty?

      role
    end
  end
end
