#!/bin/bash

# Absolute path to the directory containing the use cases execution
SCRIPTS_DIR="/app/src/execution"
RUBY_PATH="/app/vendor/bundle/ruby/3.3.0"

# Environment variables
ENV_VARS=(
    # RUBY CONFIG
    "PATH=$PATH"
    "GEM_HOME=$RUBY_PATH"
    "GEM_PATH=$RUBY_PATH"

    # DATABASE
    "DB_HOST=$DB_HOST"
    "DB_PORT=$DB_PORT"
    "DB_NAME=$DB_NAME"
    "DB_USER=$DB_USER"
    "DB_PASSWORD=$DB_PASSWORD"

    # BOT NAME
    "DISCORD_BOT_NAME=$DISCORD_BOT_NAME"

    # NOTION
    "NOTION_SECRET=$NOTION_SECRET"

    # BIRTHDAY
    "BIRTHDAY_TABLE=$BIRTHDAY_TABLE"
    "BIRTHDAY_NOTION_DATABASE_ID=$BIRTHDAY_NOTION_DATABASE_ID"
    "BIRTHDAY_DISCORD_WEBHOOK=$BIRTHDAY_DISCORD_WEBHOOK"
    "NEXT_WEEK_BIRTHDAY_DISCORD_WEBHOOK=$NEXT_WEEK_BIRTHDAY_DISCORD_WEBHOOK"

    # PTO
    "PTO_TABLE=$PTO_TABLE"
    "PTO_NOTION_DATABASE_ID=$PTO_NOTION_DATABASE_ID"
    "OPENAI_SECRET=$OPENAI_SECRET"
    "PTO_OPENAI_ASSISTANT=$PTO_OPENAI_ASSISTANT"
    "NEXT_WEEK_PTO_OPENAI_ASSISTANT=$NEXT_WEEK_PTO_OPENAI_ASSISTANT"
    "PTO_DISCORD_WEBHOOK=$PTO_DISCORD_WEBHOOK"
    "NEXT_WEEK_PTO_DISCORD_WEBHOOK=$NEXT_WEEK_PTO_DISCORD_WEBHOOK"

    # WIP LIMIT
    "WIP_TABLE=$WIP_TABLE"
    "WIP_COUNT_NOTION_DATABASE_ID=$WIP_COUNT_NOTION_DATABASE_ID"
    "WIP_LIMIT_NOTION_DATABASE_ID=$WIP_LIMIT_NOTION_DATABASE_ID"
    "WIP_LIMIT_DISCORD_WEBHOOK=$WIP_LIMIT_DISCORD_WEBHOOK"

    # SUPPORT ERMAIL
    "SUPPORT_EMAIL_TABLE=$SUPPORT_EMAIL_TABLE"
    "SUPPORT_EMAIL_ACCOUNT=$SUPPORT_EMAIL_ACCOUNT"
    "SUPPORT_EMAIL_REFRESH_TOKEN=$SUPPORT_EMAIL_REFRESH_TOKEN"
    "SUPPORT_EMAIL_CLIENT_ID=$SUPPORT_EMAIL_CLIENT_ID"
    "SUPPORT_EMAIL_CLIENT_SECRET=$SUPPORT_EMAIL_CLIENT_SECRET"
    "SUPPORT_EMAIL_INBOX=$SUPPORT_EMAIL_INBOX"
    "SUPPORT_EMAIL_RECEPTOR=$SUPPORT_EMAIL_RECEPTOR"
    "SUPPORT_EMAIL_DISCORD_WEBHOOK=$SUPPORT_EMAIL_DISCORD_WEBHOOK"
)

# Temporary file to store the new crontab
TEMP_CRONTAB=$(mktemp)

# Add environment variables to the crontab file
for ENV_VAR in "${ENV_VARS[@]}"
do
    echo "$ENV_VAR" >> $TEMP_CRONTAB
done

# Iterate over each folder in the base directory
for folder in "$SCRIPTS_DIR"/*; do
  # Check if it is a directory
  if [ -d "$folder" ]; then
    # Check if schedules.sh exists and is executable
    if [ -x "$folder/schedules.sh" ]; then
      echo "Executing schedules.sh in $folder"
      # Execute the script
      "$folder/schedules.sh" >> $TEMP_CRONTAB
    else
      echo "schedules.sh not found or not executable in $folder"
    fi
  fi
done

# Install the new crontab
crontab $TEMP_CRONTAB

# Clean up
rm $TEMP_CRONTAB

cron -f