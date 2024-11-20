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
   - Define any new tables required for shared storage in the `db/build_shared_storage.sql` file.

To activate the cronjob on the docker container execute the `update_container.sh` script (this is executed each time the container is restarted):
```bash
docker exec bas_cronjobs bash /app/scripts/update_container.sh
```
