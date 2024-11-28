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
ruby /app/src/use_cases_execution/orchestrator.rb
