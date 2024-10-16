#!/bin/bash

ENV_FILE="/app/.env"

echo "Starting update container script"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

echo "Starting sidekiq"

sidekiq -r /app/src/workers.rb -C /app/sidekiq.yml &

# Keep the container alive
tail -f /dev/null