#!/bin/bash

ENV_FILE="/app/.env"

echo "Starting update container script"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

export GEM_HOME="/app/vendor/bundle/ruby/3.3.0"
export GEM_PATH="/app/vendor/bundle/ruby/3.3.0"

echo "Starting discord bot"

# ACTIVATE BOT
ruby /app/bin/discord_images.rb &

echo "Starting cronjobs"

# UPDATE CRONJOBS
bash /app/scripts/cronjobs_set.sh
