#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rake'
require 'dotenv/load'

require_relative 'migration_operations'

shared_storage_config = {
  adapter: 'postgres',
  host: ENV.fetch('DB_HOST'),
  database: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD'),
  port: ENV.fetch('DB_PORT')
}

warehouse_config = {
  adapter: 'postgres',
  host: ENV.fetch('DB_HOST_WAREHOUSE'),
  database: ENV.fetch('WAREHOUSE_POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER_WAREHOUSE'),
  password: ENV.fetch('POSTGRES_PASSWORD_WAREHOUSE'),
  port: ENV.fetch('DB_PORT_WAREHOUSE')
}

SHARED_STORAGE_DB = MigrationOperations.new(shared_storage_config, :bas_use_cases_schema_migrations, '../db/migrations')
WAREHOUSE_DB = MigrationOperations.new(warehouse_config, :bas_warehouse_schema_migrations, '../db/warehouse_migrations')

namespace :shared_storage do
  desc 'Migrate the database'
  task :migrate do
    SHARED_STORAGE_DB.migrate_database
  end

  desc 'Rollback the last migration'
  task :rollback do
    SHARED_STORAGE_DB.rollback_database
  end

  desc 'Generate a new migration file'
  task :generate_migration, [:name] do |_t, args|
    SHARED_STORAGE_DB.generate_migration_file(args[:name])
  end
end

namespace :warehouse do
  desc 'Migrate the database'
  task :migrate do
    WAREHOUSE_DB.migrate_database
  end

  desc 'Rollback the last migration'
  task :rollback do
    WAREHOUSE_DB.rollback_database
  end

  desc 'Generate a new migration file'
  task :generate_migration, [:name] do |_t, args|
    WAREHOUSE_DB.generate_migration_file(args[:name])
  end
end
