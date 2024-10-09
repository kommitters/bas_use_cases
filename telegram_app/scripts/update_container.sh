#!/bin/bash

ENV_FILE="/app/.env"

echo "Starting update container script"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

export GEM_HOME="/usr/local/bundle"
export GEM_PATH="/usr/local/bundle"

# ACTIVATE BOT
echo "Starting telegram bot"
ruby /app/bin/web_availability.rb &

# UPDATE CRONJOBS
echo "Starting cronjobs"
bash /app/scripts/cronjobs_set.sh
