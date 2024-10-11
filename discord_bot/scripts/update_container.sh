#!/bin/bash

ENV_FILE="/app/.env"

echo "Starting update container script"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

# export GEM_HOME="/usr/local/bundle/ruby/3.3.0"
# export GEM_PATH="/usr/local/bundle/ruby/3.3.0"

echo "Starting discord bot"

# ACTIVATE BOT
ruby /app/bin/discord_images.rb &

# CREATE DB
ruby /app/scripts/create_review_media_table.rb

echo "Starting cronjobs"
