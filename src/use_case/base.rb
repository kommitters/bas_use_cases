# frozen_string_literal: true

require 'logger'
require 'sidekiq'
require 'sidekiq-scheduler'
require 'json'

module UseCase
  # UseCase::Base
  #
  class Base
    include Sidekiq::Worker

    def perform
      execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    protected

    def execute
      raise StandardError, 'missing execute method'
    end

    def connection
      {
        host: ENV.fetch('DB_HOST'),
        port: ENV.fetch('DB_PORT'),
        dbname: 'bas',
        user: ENV.fetch('POSTGRES_USER'),
        password: ENV.fetch('POSTGRES_PASSWORD')
      }
    end
  end
end
