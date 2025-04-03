
# UPDATE DATABASE
echo "UPDATE DATABASE"
ruby /app/scripts/update_database.rb
echo "DATABASE UPDATED"

# UPDATE CRONJOBS
echo "INITIALIZE CRONJOBS"
ruby /app/scripts/execute_orchestrator.rb
