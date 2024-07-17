#!/bin/bash

ENV_FILE="/app/.env"

# Load the environment variables from the .env file
set -a
source $ENV_FILE
set +a

export GEM_HOME="/app/vendor/bundle/ruby/3.3.0"
export GEM_PATH="/app/vendor/bundle/ruby/3.3.0"

# UPDATE DATABASE
ruby /app/scripts/update_database.rb

# UPDATE CRONJOBS
bash /app/scripts/activate_cronjobs.sh
