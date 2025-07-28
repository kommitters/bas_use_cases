# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'time'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'

module Routes
  # Routes::FormSubmissions defines the /webhook endpoint that receives Website form submission data
  class FormSubmissions < Sinatra::Base
    write_options = {
      connection: Config::CONNECTION,
      db_table: 'website_form_contact',
      tag: 'WebsiteContactForm'
    }

    post '/webhook' do
      content_type :json

      begin
        request_body = request.body.read
        halt 400, { error: 'Empty request body' }.to_json if request_body.strip.empty?

        data = JSON.parse(request_body)
        halt 400, { error: 'Invalid JSON format' }.to_json unless data.is_a?(Hash) && !data.empty?
      rescue JSON::ParserError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end

      begin
        shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)
        shared_storage.write(success: data)
      rescue StandardError
        halt 500, { error: 'Internal Server Error' }.to_json
      end

      status 200
      { message: 'Form submission received successfully' }.to_json
    end
  end
end
