#!/bin/bash

ENV_FILE="/app/.env"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

export GEM_HOME="/usr/local/bundle"
export GEM_PATH="/usr/local/bundle"

# UPDATE DATABASE
ruby /app/scripts/update_database.rb

# UPDATE CRONJOBS
bash /app/scripts/activate_cronjobs.sh
