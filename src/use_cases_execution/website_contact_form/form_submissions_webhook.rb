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
    post '/webhook' do
      write_options = {
        connection: Config::CONNECTION,
        db_table: 'website_form_contact',
        tag: 'WebsiteContactForm'
      }

      shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)
      request_body = request.body.read
      data = JSON.parse(request_body)

      begin
        shared_storage.write(success: data) unless data.nil?
      rescue StandardError => e
        logger.error "Failed to process message: #{e.message}"
        halt 500, 'Internal Server Error'
      end

      status 200
    end
  end
end
