#!/bin/bash

ENV_FILE="/app/.env"

echo "Starting update container script"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

echo "Starting discord bot"

# ACTIVATE BOT
ruby /app/bin/discord_images.rb

# Keep the container alive
tail -f /dev/null
