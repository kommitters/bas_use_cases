# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'time'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../implementations/fetch_pto_from_google'

module Routes
  # Routes::FormSubmissions defines the /webhook endpoint that receives Website form submission data
  class FormSubmissions < Sinatra::Base
    # Enable CORS for local developement
    before do
      response.headers['Access-Control-Allow-Origin'] = 'http://localhost:4321' # your frontend's origin
      response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    end

    # Preflight requests handling
    options '*' do
      200
    end

    write_options = {
      connection: Config::CONNECTION,
      db_table: 'website_form_contact',
      tag: 'WebsiteContactForm'
    }

    shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)

    post '/webhook' do
      request_body = request.body.read
      data = JSON.parse(request_body)

      puts 'ON /WEBHOOK'
      puts data

      begin
        puts 'WRITTING....'
        shared_storage.write(success: data) unless data.nil?
      rescue StandardError => e
        puts e
        logger.error "Failed to process message: #{e.message}"
        status 500
        body 'Internal Server Error'
      end

      status 200
    end
  end
end
