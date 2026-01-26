#!/usr/bin/env bash
set -euo pipefail

echo "UPDATE SHARED STORAGE DATABASE"
bundle exec rake -f /app/scripts/update_database.rb shared_storage:migrate
echo "SHARED STORAGE DATABASE UPDATED"

echo "INITIALIZE CRONJOBS"
exec bundle exec ruby /app/scripts/execute_orchestrator.rb
