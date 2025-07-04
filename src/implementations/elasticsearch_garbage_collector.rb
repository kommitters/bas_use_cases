# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/elasticsearch/request'

module Implementation
  ##
  # The Implementation::ElasticsearchGarbageCollector class serves as a bot implementation to archive bot records from a
  # Elasticsearch database index and write a response on a Elasticsearch index with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   options = {
  #     connection:,
  #     index: "birthdays"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Default.new
  #
  #  Implementation::ElasticsearchGarbageCollector.new(options, shared_storage).execute
  #
  class ElasticsearchGarbageCollector < Bas::Bot::Base
    # Process function to update records in a Elasticsearch database index
    #
    def process
      Utils::Elasticsearch::Request.execute(params)
      { success: { archived: true } }
    end

    private

    def params
      {
        connection: process_options[:connection],
        index: process_options[:index],
        method: :update,
        body: update_body
      }
    end

    def update_body
      {
        query: { term: { archived: false } },
        script: {
          source: 'ctx._source.archived = params.new_value',
          lang: 'painless',
          params: { new_value: true }
        }
      }
    end
  end
end
