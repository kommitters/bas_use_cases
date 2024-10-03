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

    # WEBISTE AVAILABILITY
    "TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN"
)

# Temporary file to store the new crontab
TEMP_CRONTAB=$(mktemp)

# Add environment variables to the crontab file
for ENV_VAR in "${ENV_VARS[@]}"
do
    echo "$ENV_VAR" >> $TEMP_CRONTAB
done

echo "*/1 * * * * /usr/local/bin/ruby /app/lib/cronjobs/fetch_webistes_review_request.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB
echo "*/1 * * * * /usr/local/bin/ruby /app/lib/cronjobs/write_domain_review_request.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB
echo "*/1 * * * * /usr/local/bin/ruby /app/lib/cronjobs/review_website_availability.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB
echo "*/1 * * * * /usr/local/bin/ruby /app/lib/cronjobs/notify_telegram.rb >> /app/logs.log 2>&1" >> $TEMP_CRONTAB

# Install the new crontab
crontab $TEMP_CRONTAB

# Clean up
rm $TEMP_CRONTAB

cron -f
