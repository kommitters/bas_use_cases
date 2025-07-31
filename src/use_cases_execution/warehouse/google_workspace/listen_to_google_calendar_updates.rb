# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../../implementations/format_workspace_calendar_events'

module Routes
  # Routes::CalendarEvents defines the /calendar_events endpoint
  class CalendarEvents < Sinatra::Base
    def initialize(args)
      super(args)
      write_options = {
        connection: Config::CONNECTION, db_table: 'warehouse_sync', tag: 'FetchCalendarEventsFromWebhook'
      }
      @shared_storage_reader = Bas::SharedStorage::Default.new
      @shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
    end

    ##
    # POST /calendar_events
    #
    # Receives Google Calendar activity data from an Apps Script webhook.
    #
    post '/calendar_events' do
      body = request.body.read.to_s
      halt 400, { error: 'Empty request body' }.to_json if body.strip.empty?
      data = JSON.parse(body)

      unless data.is_a?(Hash) && data['calendar_events'].is_a?(Array)
        halt 400, { error: 'Missing or invalid "calendar_events" array' }.to_json
      end

      options = { calendar_events: data['calendar_events'] }
      Implementation::FormatWorkspaceCalendarEvents.new(options, @shared_storage_reader, @shared_storage_writer).execute

      status 200
      { message: 'Calendar events stored successfully' }.to_json
    rescue JSON::ParserError => e
      logger.error "Invalid JSON format: #{e.message}"
      status 400
      { error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      logger.error "Failed to process calendar events data: #{e.message}\n#{e.backtrace.join("\n")}"
      halt 500, { error: 'Internal Server Error' }.to_json
    end
  end
end
