# UPDATE SHARED STORAGE DATABASE
echo "UPDATE SHARED STORAGE DATABASE"
rake -f /app/scripts/update_database.rb shared_storage:migrate
echo "SHARED STORAGE DATABASE UPDATED"

# INITIALIZE CRONJOBS
echo "INITIALIZE CRONJOBS"
ruby /app/scripts/execute_orchestrator.rb
