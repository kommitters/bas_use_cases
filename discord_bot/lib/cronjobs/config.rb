# frozen_string_literal: true

module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    database: ENV.fetch('POSTGRES_DB'),
    username: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze
end
