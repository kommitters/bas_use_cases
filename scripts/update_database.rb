#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pg'
require 'sequel'
require 'rake'
require 'fileutils'
require 'dotenv/load'

DB = Sequel.connect(
  adapter: 'postgres',
  host: ENV.fetch('DB_HOST'),
  database: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD'),
  port: ENV.fetch('DB_PORT')
)

Sequel.extension :migration

def migrate_database
  puts 'Migrating the database...'
  Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__))
  puts 'Database migration complete.'
end

def rollback_database
  puts 'Rolling back the last migration...'
  applied_migrations = fetch_applied_migrations

  if applied_migrations.empty?
    puts 'No migrations to rollback.'
    return
  end

  last_migration = applied_migrations.last
  target_migration = calculate_target_migration(applied_migrations)
  run_rollback(target_migration, last_migration)
end

def fetch_applied_migrations
  DB[:schema_migrations].select_order_map(:filename).sort
end

def calculate_target_migration(applied_migrations)
  if applied_migrations.length > 1
    applied_migrations[-2].split('_').first.to_i
  else
    0
  end
end

def run_rollback(target_migration, last_migration)
  Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__), target: target_migration)
  puts "Rollback complete. Rolled back from #{last_migration} to #{target_migration}."
end

def generate_migration_file(name)
  raise 'You must provide a migration name, e.g., rake db:generate_migration[add_users_table]' unless name

  timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  filename = "#{timestamp}_#{name}.rb"
  migration_dir = File.expand_path('../db/migrations', __dir__)
  FileUtils.mkdir_p(migration_dir)
  filepath = File.join(migration_dir, filename)

  write_migration_template(filepath)
  puts "Created migration: #{filepath}"
end

def write_migration_template(filepath)
  File.open(filepath, 'w') do |file|
    file.puts <<~MIGRATION
      # frozen_string_literal: true

      Sequel.migration do
        up do
          # Define your migration changes here
        end

        down do
          # Revert your migration changes here
        end
      end
    MIGRATION
  end
end

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    migrate_database
  end

  desc 'Rollback the last migration'
  task :rollback do
    rollback_database
  end

  desc 'Generate a new migration file'
  task :generate_migration, [:name] do |_t, args|
    generate_migration_file(args[:name])
  end
end
