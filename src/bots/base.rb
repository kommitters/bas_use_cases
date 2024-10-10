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

    def initialize; end

    protected

    def perform; end

    def conenction
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
