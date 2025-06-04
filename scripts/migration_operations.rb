# frozen_string_literal: true

require 'sequel'
require 'fileutils'

##
# Database Migration Operations Manager
#
# A reusable class for managing Sequel database migrations across multiple databases.
# This class encapsulates all migration operations including running migrations,
# rolling back changes, and generating new migration files.
class MigrationOperations
  Sequel.extension :migration

  def initialize(config, migration_table, migration_dir)
    @db = Sequel.connect(config)
    @migration_dir = File.expand_path(migration_dir, __dir__)
    @migration_table = migration_table
  end

  def migrate_database
    puts 'Migrating the database...'
    Sequel::Migrator.run(@db, @migration_dir, table: @migration_table)
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

  def generate_migration_file(name)
    raise 'You must provide a migration name, e.g., rake db:generate_migration[add_users_table]' unless name

    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    filename = "#{timestamp}_#{name}.rb"
    FileUtils.mkdir_p(@migration_dir)
    filepath = File.join(@migration_dir, filename)

    write_migration_template(filepath)
    puts "Created migration: #{filepath}"
  end

  private

  def fetch_applied_migrations
    @db[@migration_table].select_order_map(:filename).sort
  end

  def calculate_target_migration(applied_migrations)
    if applied_migrations.length > 1
      applied_migrations[-2].split('_').first.to_i
    else
      0
    end
  end

  def run_rollback(target_migration, last_migration)
    Sequel::Migrator.run(@db, @migration_dir, target: target_migration,
                                              table: @migration_table)
    puts "Rollback complete. Rolled back from #{last_migration} to #{target_migration}."
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
end
