#!/usr/local/bin/ruby
# frozen_string_literal: true

require 'pg'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

sql = "CREATE TABLE IF NOT EXISTS review_images (
        id SERIAL NOT NULL,
        \"data\" jsonb,
        tag varchar(255),
        archived boolean,
        stage varchar(255),
        status varchar(255),
        error_message jsonb,
        version varchar(255),
        inserted_at timestamp
        with
          time zone DEFAULT CURRENT_TIMESTAMP,
          updated_at timestamp
        with
          time zone DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id)
      );"

pg_connection = PG::Connection.new(connection)

begin
  # Execute the SQL script
  pg_connection.exec(sql)
  puts 'SQL script executed successfully!'
rescue PG::Error => e
  puts e.message
ensure
  # Close the connection
  pg_connection&.close
end
