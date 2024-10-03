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
    "POSTGRES_DB=$POSTGRES_DB"
    "POSTGRES_USER=$POSTGRES_USER"
    "POSTGRES_PASSWORD=$POSTGRES_PASSWORD"
    "REVIEW_IMAGES_TABLE=$REVIEW_IMAGES_TABLE"

    # DISCORD BOT
    "DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN"

    #OPENAI
    "OPENAI_ASSISTANT_ID=$OPENAI_ASSISTANT_ID"
    "OPENAI_SECRET=$OPENAI_SECRET"
)

# Temporary file to store the new crontab
TEMP_CRONTAB=$(mktemp)

# Add environment variables to the crontab file
for ENV_VAR in "${ENV_VARS[@]}"
do
  echo "$ENV_VAR" >> $TEMP_CRONTAB
done

# cat $TEMP_CRONTAB

echo "* * * * * /usr/local/bin/ruby /app/lib/cronjobs/review_media.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB
echo "* * * * * /usr/local/bin/ruby /app/lib/cronjobs/write_media_review_in_discord.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB


# Install the new crontab
crontab $TEMP_CRONTAB

# Clean up
rm $TEMP_CRONTAB

cron -f
