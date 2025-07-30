# UPDATE SHARED STORAGE DATABASE
echo "UPDATE SHARED STORAGE DATABASE"
rake -f /app/scripts/update_database.rb shared_storage:migrate
echo "SHARED STORAGE DATABASE UPDATED"

# UPDATE WAREHOUSE DATABASE
echo "UPDATE WAREHOUSE DATABASE"
rake -f /app/scripts/update_database.rb warehouse:migrate
echo "WAREHOUSE DATABASE UPDATED"

# UPDATE CRONJOBS
echo "INITIALIZE CRONJOBS"
ruby /app/scripts/execute_orchestrator.rb
