# BAS use cases implementation structure

Use cases implementation for the BAS Project: This project serves as a template for creating use cases such as birthday or PTO notifications. It extracts information from a source like Notion and publishes it on a receiver like Discord with an specific schedule.

## Project Requirements

- Ruby 3.2
- Node 18.13.0

## Setup

Clone the repository

```bash
git clone git@github.com:kommitters/bas_serverless.git
cd bns_serverless
```

Install ruby dependencies

```bash
bundle install --path vendor/bundle
```

Build docker containers:

```bash
# Build containers: just first time
docker-compose up --build

# To start the containers
docker-compose up
```

## Environment variables

Create the environment variables configuration file.

```bash
cp env.yml.example env.yml
```

On this file, you can add the environment variables depending on the environment you are in. For example, for a use case with Notion as a read and Discord as the process:

```
dev:
  NOTION_DATABASE_ID: NOTION_DATABASE_ID
  NOTION_SECRET: NOTION_SECRET
  DISCORD_WEBHOOK: DISCORD_WEBHOOK
  DISCORD_BOT_NAME: DISCORD_BOT_NAME
prod:
  NOTION_DATABASE_ID: NOTION_DATABASE_ID
  NOTION_SECRET: NOTION_SECRET
  DISCORD_WEBHOOK: DISCORD_WEBHOOK
  DISCORD_BOT_NAME: DISCORD_BOT_NAME

```

## Schedule

For each use case, the bots schedules are configured on the `schedule.sh` script inside the CRON_JOBS tuple. Example:

```bash
CRON_JOBS=(
    "51 20 * * * fetch_pto_from_notion.rb"
    "52 20 * * * humanize_pto.rb"
    "53 20 * * * notify_pto_in_discord.rb"
    "54 20 * * * garbage_collector.rb"
)
```

To learn how to modify the cron configuration follow this guide: [Schedule expressions using rate or cron](https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html)

> The environment variable should be defined with the quotes, specially if is set as a github secret. Example:

```bash
# Schedule definition
"0 13,15,19,21 ? * MON-FRI *"
```

## Build a New Use Case

To add a new use case:

1. **Define the Bots**:

   - If the required bots are not already defined, create them in the `src/implementations` folder.

2. **Model the Use Case**:

   - In the `src/use_cases_execution` folder, create a new folder for the use case. This folder should:
     - Call the necessary bots from the `implementations` folder, modeling the use case and its specific parameters.
     - Contain a `schedule.sh` script where the cronjob schedules for the bots will be configured.

3. **Update Shared Storage**:
   - Define any new tables required for shared storage using migrations.

To activate the cronjob on the docker container execute the `update_container.sh` script (this is executed each time the container is restarted):

```bash
docker exec bas_cronjobs bash /app/scripts/update_container.sh
```

---

## Database Migrations

The project uses a migration system based on [Sequel](https://sequel.jeremyevans.net/) and Rake to manage database schema changes.

### How It Works

- There is a dedicated migration file for each table: use `db/migrations/` for shared storage tables and `db/warehouse_migrations/` for warehouse tables.
- Migrations are versioned and can be applied or rolled back, providing version control for your database schema.
- You can safely add, modify, or remove tables and columns over time.

### How to Generate a Migration

To generate a migration file for a new table, run:

```bash
# SHARED STORAGE
rake -f scripts/update_database.rb shared_storage:generate_migration[create_table_name]

# WAREHOUSE
rake -f scripts/update_database.rb warehouse:generate_migration[create_table_name]
```

For example, for the shared storage `birthday` table:

```bash
# SHARED STORAGE
rake -f scripts/update_database.rb shared_storage:generate_migration[create_birthday]
```

This will generate a file in the migrations folder `db/migrations/` that you can edit to define your table structure.

### How to Apply Migrations

To apply all pending migrations to the database:

```bash
# SHARED STORAGE
rake -f scripts/update_database.rb shared_storage:migrate

# WAREHOUSE
rake -f scripts/update_database.rb warehouse:migrate
```

### How to Roll Back the Last Migration

To undo the last applied migration:

```bash
# SHARED STORAGE
rake -f scripts/update_database.rb shared_storage:rollback

# WAREHOUSE
rake -f scripts/update_database.rb warehouse:rollback
```

### Migration File Example

```ruby
Sequel.migration do
  up do
    create_table?(:birthday) do
      primary_key :id
      column :data, :jsonb
      String :tag, size: 255
      TrueClass :archived
      String :stage, size: 255
      String :status, size: 255
      column :error_message, :jsonb
      String :version, size: 255
      DateTime :inserted_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table?(:birthday)
  end
end
```

You should create a similar migration for each table you need (see the migrations folders).

---

### Using Claude Code

Claude Code can be used to implement new use cases, just follow the instructions on `CLAUDE_USAGE.md`
